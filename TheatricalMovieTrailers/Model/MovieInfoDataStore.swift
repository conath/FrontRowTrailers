//
//  MovieInfoDataStore.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 22.10.20.
//

import Combine
import Network
import UIKit

class MovieInfoDataStore: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    /// Monitor network connection
    private let monitor: NWPathMonitor

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    /// Movie Trailer Data
    var moviesAvailable: Bool {
        model.count > 0
    }
    @Published private(set) var model = [MovieInfo]()
    /// Whether streaming trailers from the internet is available.
    @Published private(set) var streamingAvailable = false
    /// Shared UI State
    @Published var error: AppError? = nil
    @Published var idsAndImages = [Int: UIImage?]()
    @Published var watched: [Int: Bool]
    @Published var selectedTrailerModel: MovieInfo?
    @Published var posterImage: UIImage?
    @Published var isPlaying = false
    /// Singleton
    static let shared = MovieInfoDataStore()
    
    // MARK: File URLs
    private var localStorageDirectory: URL {
        let fileManager = FileManager.default
        guard let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Couldn't get local storage directory (.cachesDirectory)")
        }
        return url
    }
    private var localCurrentTrailersURL: URL {
        return localStorageDirectory.appendingPathComponent("currentTrailers.xml")
    }
    private var localMoviePostersURL: URL {
        return localStorageDirectory.appendingPathComponent("Movie Posters", isDirectory: true)
    }
    private var currentTrailersURL: URL {
        var urlString: String!
        if Settings.instance.loadHighDefinition {
            urlString = "https://trailers.apple.com/trailers/home/xml/current_720p.xml"
        } else {
            urlString = "https://trailers.apple.com/trailers/home/xml/current.xml"
        }
        return URL(string: urlString)!
    }
    
    private init() {
        watched = Self.getWatchedTrailers()
        /// monitor if connected to the internet to enable/disable trailer buttons
        let monitor = NWPathMonitor()
        self.monitor = monitor
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
                    if !self.moviesAvailable {
                        self.downloadTrailers()
                    }
                } else {
                    /// offline
                    self.streamingAvailable = false
                }
            }
        }
        monitor.start(queue: .global(qos: .background))
        
        /// Do we want to download latest trailers?
        if let lastDownloaded = modifiedDate(atURL: localCurrentTrailersURL) {
            let age = lastDownloaded.distance(to: Date())
            let numberOfSecondsInThreeDays: Double = 3*24*60*60
            if age < numberOfSecondsInThreeDays {
                // no need to re-download the XML
                loadTrailersFromDisk()
                return
            }
        }
        
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
        $watched
            .dropFirst()
            .sink { (watched: [Int:Bool]) in
                Self.storeWatchedTrailers(watched)
            }
            .store(in: &cancellables)
    }
    
    private func loadTrailersFromDisk() {
        let parserDelegate = MovieInfoXMLParserDelegate { maybeModel in
            if let model = maybeModel {
                self.model = model.sorted(by: SortingMode.ReleaseAscending.predicate)
                self.fetchPosterImagesFor(model: model)
            }
        }
        loadTrailers(parserDelegate: parserDelegate)
    }
    
    func downloadTrailers() {
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
                // try to load local trailers file
                loadTrailersFromDisk()
            } else if let tempUrl = url {
                DispatchQueue.main.async {
                    streamingAvailable = true
                }
                /// Copy the downloaded file to the offline currentTrailers path
                let fileManager = FileManager.default
                do {
                    // attempt to create local storage directory, which throws if the directory exists
                    do {
                        try fileManager.createDirectory(at: localStorageDirectory, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        // exists, continue
                    }
                    // attempt to create movie posters directory
                    do {
                        try fileManager.createDirectory(at: localMoviePostersURL, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        // exists, continue
                    }
                    // does a temp file exist at the location?
                    if fileManager.fileExists(atPath: localCurrentTrailersURL.relativePath) {
                        try fileManager.removeItem(at: localCurrentTrailersURL)
                    }
                    try fileManager.moveItem(at: tempUrl, to: localCurrentTrailersURL)
                } catch {
                    // TODO
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
                // when finished, completion is called by the parser
            } else {
                DispatchQueue.main.async {
                    parserDelegate.completion(nil)
                }
            }
        }
    }
    
    /// Tries to load the poster image for each `MovieInfo` in `movies` from disk, or from the network if a poster image is not found on disk.
    private func fetchPosterImagesFor(model movies: [MovieInfo]) {
        /// Tries to load an image from the passed `URL` and stores it to `idsAndImages`.
        func loadImageFrom(url: URL?, id: Int) -> UIImage? {
            if let url = url, let data = try? Data(contentsOf: url) {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.idsAndImages.updateValue(image, forKey: id)
                }
                return image
            } else {
                DispatchQueue.main.async {
                    self.idsAndImages.updateValue(nil, forKey: id)
                }
                return nil
            }
        }
            
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let fileManager = FileManager.default
            for movieInfo in movies {
                let localURL = localMoviePostersURL.appendingPathComponent("\(movieInfo.id).jpg")
                if fileManager.fileExists(atPath: localURL.relativePath) {
                    /// load from disk
                    _ = loadImageFrom(url: localURL, id: movieInfo.id)
                } else {
                    /// download from network
                    guard streamingAvailable else { continue }
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
            }
        }
    }
    
    private func modifiedDate(atURL url: URL) -> Date? {
        if let attr = try? url.resourceValues(forKeys: [URLResourceKey.contentModificationDateKey]) {
            return attr.contentModificationDate
        }
        return nil
    }
    
    private class func getWatchedTrailers() -> [Int:Bool] {
        let defaults = UserDefaults()
        return defaults.value(forKey: .watchedTrailers) as? [Int:Bool] ?? [:]
    }
    
    /// Stores the `watched` dictionary in `UserDefaults`.
    private class func storeWatchedTrailers(_ watched: [Int:Bool]) {
        let defaults = UserDefaults()
        if var prevWatched = defaults.object(forKey: .watchedTrailers) as? [Int:Bool] {
            // update values
            for (id, value) in watched {
                prevWatched.updateValue(value, forKey: id)
            }
            defaults.setValue(prevWatched, forKey: .watchedTrailers)
        } else {
            // new
            defaults.setValue(watched, forKey: .watchedTrailers)
        }
    }
}

fileprivate extension String {
    static let watchedTrailers = "watchedTrailers"
}
