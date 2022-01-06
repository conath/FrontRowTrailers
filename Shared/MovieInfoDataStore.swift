//
//  MovieInfoDataStore.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 22.10.20.
//

import Combine
import Network
import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import TelemetryClient

class MovieInfoDataStore: ObservableObject {
#if os(iOS)
    /// need the platform-dependent image class to we can create an image from data
    typealias PlatformImage = UIKit.UIImage
    private let appGroupID = "group.cafe.chrisp.tmt"
#elseif os(macOS)
    typealias PlatformImage = AppKit.NSImage
    private let appGroupID = "U96PJYMZWW.tmt-group"
#endif
    
    static let urlScheme = "theatricals://showTrailer?id="
    static let currentTrailersHDURL = URL(string: "https://trailers.apple.com/trailers/home/xml/current_720p.xml")!
    static let currentTrailersSDURL = URL(string: "https://trailers.apple.com/trailers/home/xml/current.xml")!
    
    private var cancellables = Set<AnyCancellable>()
    /// Monitor network connection
    private let monitor: NWPathMonitor
    
    /// Movie Trailer Data
    var moviesAvailable: Bool {
        model.count > 0
    }
    /// Callback that is called when the movie info is loaded, and before poster images are downloaded. Return the `MovieInfo`s for which images should be fetched.
    var onMoviesAvailable: (([MovieInfo]?) -> ([MovieInfo]))? {
        didSet {
            if moviesAvailable {
                if let imagesToFetch = onMoviesAvailable?(model) {
                    fetchPosterImagesFor(model: imagesToFetch, completion: {
                        self.onImagesAvailable?(imagesToFetch)
                    })
                }
                onMoviesAvailable = nil
            }
        }
    }
    /// Callback that is called when the movie posters requested as return value of `onMoviesAvailable` are downloaded, or if images were already ready, all `MovieInfo`s. Use `idsAndImages` with `MovieInfo.id` as the key to get the poster image for a movie.
    var onImagesAvailable: (([MovieInfo]) -> ())? {
        didSet {
            if idsAndImages.count > 0, idsAndImages.count == model.count {
                onImagesAvailable?(model)
                onImagesAvailable = nil
            }
        }
    }
    @Published var model = [MovieInfo]()
    @Published var lastUpdated: Date? = nil
    /// Whether streaming trailers from the internet is available.
    @Published private(set) var streamingAvailable = false
    /// Shared UI State
    @Published var error: AppError? = nil
    @Published var idsAndImages = [Int: Image?]()
    
    @Published private(set) var watched: [Int]
    @Published var selectedTrailerModel: MovieInfo?
    @Published var posterImage: Image?
    @Published var isPlaying = false
    /// Singleton
    static let shared = MovieInfoDataStore()
    
    // MARK: File URLs
    private var localStorageDirectory: URL {
        let fileManager = FileManager.default
        guard let sharedContainerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID) else {
                fatalError("Couldn't get App Group shared container.")
            }
        return sharedContainerURL
    }
    private var localCurrentTrailersURL: URL {
        return localStorageDirectory.appendingPathComponent("currentTrailers.xml")
    }
    private var localMoviePostersURL: URL {
        return localStorageDirectory.appendingPathComponent("Movie Posters", isDirectory: true)
    }
    private var currentTrailersURL: URL {
        if Settings.instance.loadHighDefinition {
            return Self.currentTrailersHDURL
        } else {
            return Self.currentTrailersSDURL
        }
    }
    
    private init() {
        watched = Self.getWatchedTrailers()
        
        /// monitor if connected to the internet to enable/disable trailer buttons
        let monitor = NWPathMonitor()
        self.monitor = monitor
        
        var isLoading = false
        /// Do we want to download latest trailers?
        if let lastDownloaded = modifiedDate(atURL: localCurrentTrailersURL) {
            let age = lastDownloaded.distance(to: Date())
            let numberOfSecondsInThreeDays: Double = 3*24*60*60
            if age < numberOfSecondsInThreeDays {
                lastUpdated = lastDownloaded
                /// no need to re-download the XML
                loadTrailersFromDisk()
                isLoading = true
            }
        }
        /// get updates on internet connectivity
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else {
                monitor.pathUpdateHandler = nil
                return
            }
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    /// online
                    self.streamingAvailable = true
                    /// need to download trailers?
                    if isLoading {
                        return
                    } else if !self.moviesAvailable {
                        self.downloadTrailers()
                    } else {
                        /// were offline and have model –> update posters
                        self.fetchPosterImagesFor(model: self.model)
                    }
                } else {
                    /// offline
                    self.streamingAvailable = false
                    /// need to load trailers?
                    let downloaded = self.modifiedDate(atURL: self.localCurrentTrailersURL) != nil
                    if !self.moviesAvailable && !downloaded {
                        self.loadBundledTrailersXML()
                        self.error = AppError.notConnectedToInternet
                    }
                }
            }
        }
        monitor.start(queue: .global(qos: .background))
        
        /// **Combine** subscribers
        $selectedTrailerModel
            .sink(receiveValue:  { [self] selectedTrailerModel in
                if let model = selectedTrailerModel {
                    self.posterImage = idsAndImages[model.id] ?? nil
                }
                if isPlaying {
                    isPlaying = false
                    if selectedTrailerModel != nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.isPlaying = true
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    /// Asynchronously copies the trailers XML file from `currentTrailers.bundle` to the `localCurrentTrailersURL`, then calls `loadTrailersFromDisk`.
    private func loadBundledTrailersXML() {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            /// can't load trailers from cache or network - fall back to bundled XML
            guard let bundledTrailersPath = Bundle.main.path(forResource: "currentTrailers", ofType: "bundle") else {
                assertionFailure("No currentTrailers bundle included with the app!")
                return
            }
            let fileManager = FileManager.default
            guard let filenames = try? fileManager.contentsOfDirectory(atPath: bundledTrailersPath), filenames.count == 2 else {
                assertionFailure("Expected two files in currentTrailers.bundle")
                return
            }
            
            for filename in filenames {
                /// Load HD or SD XML
                if Settings.instance.loadHighDefinition != filename.contains("720p") {
                    continue
                }
                let fileURL = URL(fileURLWithPath: "\(bundledTrailersPath)/\(filename)")
                do {
                    try fileManager.copyItem(at: fileURL, to: localCurrentTrailersURL)
                } catch {
                    /// file exists error: files of this name already present
                    ///  that can happen when the download is done while this runs.
                    if error.localizedDescription.contains("exist") || error.localizedDescription.contains("ERR516") {
                        return
                    } else {
                        /// unknown errors are not handled; skip file
                        assertionFailure("Unknown error while copying image from bundle to local directory!")
                        DispatchQueue.main.async {
                            self.error = .otherError(error: error)
                        }
                        return
                    }
                }
            }
            /// local xml file exists now
            loadTrailersFromDisk()
        }
    }
    
    private func loadTrailersFromDisk() {
        let parserDelegate = MovieInfoXMLParserDelegate { maybeModel in
            if let model = maybeModel {
                self.model = model.sorted(by: SortingMode.ReleaseAscending.predicate)
                let modelToFetch = self.onMoviesAvailable?(model) ?? model
                self.onMoviesAvailable = nil
                self.fetchPosterImagesFor(model: modelToFetch) {
                    self.onImagesAvailable?(modelToFetch)
                    self.onImagesAvailable = nil
                }
            }
        }
        loadTrailers(parserDelegate: parserDelegate)
    }
    
    private func downloadTrailers() {
        /// Try downloading latest trailers
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        let task = session.downloadTask(with: currentTrailersURL) { [self] (url, response, error) in
            if let error = error as NSError? {
                DispatchQueue.main.async {
                    switch error.code {
                    case NSURLErrorNotConnectedToInternet:
                        self.error = AppError.notConnectedToInternet
                    default:
                        self.error = AppError.otherError(error: error)
                    }
                }
                /// try to load local trailers file
                loadTrailersFromDisk()
            } else if let tempUrl = url {
                DispatchQueue.main.async {
                    streamingAvailable = true
                    lastUpdated = Date()
                }
                /// Copy the downloaded file to the offline currentTrailers path
                let fileManager = FileManager.default
                do {
                    /// attempt to create local storage directory, which throws if the directory exists
                    do {
                        try fileManager.createDirectory(at: localStorageDirectory, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        /// exists, continue
                    }
                    /// attempt to create movie posters directory
                    do {
                        try fileManager.createDirectory(at: localMoviePostersURL, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        /// exists, continue
                    }
                    /// does a temp file exist at the location?
                    if fileManager.fileExists(atPath: localCurrentTrailersURL.relativePath) {
                        try fileManager.removeItem(at: localCurrentTrailersURL)
                    }
                    try fileManager.moveItem(at: tempUrl, to: localCurrentTrailersURL)
                } catch {
                    /// TODO
                    print(error)
                    DispatchQueue.main.async {
                        self.error = AppError.otherError(error: error)
                    }
                    return
                }
                /// Local `currentTrailers` file exists now
                loadTrailersFromDisk()
            }
        }
        task.resume()
    }
    
    func update() {
        if streamingAvailable {
            model = []
            idsAndImages = [:]
            downloadTrailers()
        }
    }
    
    // MARK: - Load Movie Info from XML & URL
    
    private func loadTrailers(parserDelegate: MovieInfoXMLParserDelegate) {
        guard FileManager.default.fileExists(atPath: localCurrentTrailersURL.relativePath) else {
            print("Local current trailers file wasn't found.")
            DispatchQueue.main.async {
                parserDelegate.completion(nil)
            }
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            if let xmlParser = XMLParser(contentsOf: localCurrentTrailersURL) {
                xmlParser.delegate = parserDelegate
                xmlParser.parse()
                /// when finished, completion is called by the parser
            } else {
                DispatchQueue.main.async {
                    parserDelegate.completion(nil)
                }
            }
        }
    }
    
    /// Tries to load the poster image for each `MovieInfo` in `movies` from disk, or from the network if a poster image is not found on disk.
    private func fetchPosterImagesFor(model movies: [MovieInfo], completion: (() -> ())? = nil) {
        /// Tries to load an image from the passed `URL` and stores it to `idsAndImages`.
        func loadImageFrom(url: URL?, id: Int) -> PlatformImage? {
            if let url = url, let data = try? Data(contentsOf: url) {
                let platformImage = PlatformImage(data: data)
                let swiftUIImage = platformImage == nil ? nil : Image(nsImage: platformImage!)
                DispatchQueue.main.async {
                    self.idsAndImages.updateValue(swiftUIImage, forKey: id)
                }
                return platformImage
            } else {
                DispatchQueue.main.async {
                    self.idsAndImages.updateValue(nil, forKey: id)
                }
                return nil
            }
        }
#if os(iOS)
        func tryDownloadImage(for movieInfo: MovieInfo, localURL: URL) {
            if let image = loadImageFrom(url: movieInfo.posterURL, id: movieInfo.id),
               let jpgData = image.jpegData(compressionQuality: 0.8) {
                /// store on disk
                do {
                    try jpgData.write(to: localURL)
                } catch {
                    self.error = AppError.otherError(error: error)
                }
            }
        }
#elseif os(macOS)
        func tryDownloadImage(for movieInfo: MovieInfo, localURL: URL) {
            if let image = loadImageFrom(url: movieInfo.posterURL, id: movieInfo.id),
               let bits = image.representations.first as? NSBitmapImageRep,
               let data = bits.representation(using: .jpeg, properties: [.compressionFactor:0.8]) {
                do {
                    try data.write(to: localURL)
                } catch {
                    self.error = AppError.otherError(error: error)
                }
            }
        }
#endif
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let fileManager = FileManager.default
            for movieInfo in movies {
                /// if the `id` is known and there is an image at that `id`, already loaded that
                guard !idsAndImages.keys.contains(movieInfo.id) || idsAndImages[movieInfo.id]! == nil else {
                    continue /// already have this one
                }
                let localURL = localMoviePostersURL.appendingPathComponent("\(movieInfo.id).jpg")
                if fileManager.fileExists(atPath: localURL.relativePath) {
                    /// load from disk
                    _ = loadImageFrom(url: localURL, id: movieInfo.id)
                } else {
                    /// download from network
                    guard streamingAvailable else {
                        DispatchQueue.main.async {
                            idsAndImages.updateValue(nil, forKey: movieInfo.id)
                        }
                        continue
                    }
                    tryDownloadImage(for: movieInfo, localURL: localURL)
                }
            }
            completion?()
        }
    }
    
    private func modifiedDate(atURL url: URL) -> Date? {
        if let attr = try? url.resourceValues(forKeys: [URLResourceKey.contentModificationDateKey]) {
            return attr.contentModificationDate
        }
        return nil
    }
    
    private class func getWatchedTrailers() -> [Int] {
        let defaults = UserDefaults()
        defaults.synchronize()
        return defaults.array(forKey: .watchedTrailers) as? [Int] ?? []
    }
    
    /// Stores the `watched` dictionary in `UserDefaults` and sends a Telemetry signal with
    func setWatchedTrailer(_ model: MovieInfo) {
        watched.append(model.id)
        let defaults = UserDefaults()
        defaults.setValue(watched, forKey: .watchedTrailers)
        defaults.synchronize()
        /// send without user ID to not track anyone's watching habits
        TelemetryManager.send("trailerWatched", for: "", with: ["trailerID":"\(model.id)", "movieTitle":model.title, "watchedCount":"\(watched.count)"])
    }
}

fileprivate extension String {
    static let watchedTrailers = "watchedTrailers"
}
