//
//  TrailersWidget.swift
//  TrailersWidget
//
//  Created by Chris on 28.10.20.
//

import WidgetKit
import SwiftUI
import Intents

class Provider: IntentTimelineProvider {
    let dataStore = MovieInfoDataStore.shared
    var info = [MovieInfo]()
    var images = [Int: UIImage?]()
    
    func placeholder(in context: Context) -> TrailerEntry {
        TrailerEntry(date: Date(), configuration: ConfigurationIntent(), info: MovieInfo.Empty)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TrailerEntry) -> ()) {
        let emptyEntry = TrailerEntry(date: Date(), configuration: configuration, info: MovieInfo.Empty)
        
        let dataStore = MovieInfoDataStore.shared
        dataStore.onMoviesAvailable = { model in
            guard let model = model else {
                completion(emptyEntry)
                return []
            }
            let info: [MovieInfo]
            switch configuration.trailerScope {
            case .releasingSoonest:
                let now = Date()
                info = Array(model.sorted(by: SortingMode.ReleaseAscending.predicate).filter({
                    $0.releaseDate != nil && $0.releaseDate! > now
                }).prefix(3))
            default: /// default to newest added
                info = Array(model.sorted(by: { $0.postDate > $1.postDate }).prefix(3))
            }
            let entry = TrailerEntry(date: Date(), configuration: configuration, info: info.first ?? MovieInfo.Empty)
            completion(entry)
            return info
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        /// Download `MovieInfo`s
        dataStore.onMoviesAvailable = { [self] model in
            guard let model = model else {
                let emptyEntry = TrailerEntry(date: Date(), configuration: configuration, info: MovieInfo.Empty)
                completion(Timeline(entries: [emptyEntry], policy: .atEnd))
                return []
            }
            switch configuration.trailerScope {
            case .releasingSoonest:
                let now = Date()
                info = Array(model.sorted(by: SortingMode.ReleaseAscending.predicate).filter({
                    $0.releaseDate != nil && $0.releaseDate! > now
                }).prefix(3))
            default: /// default to newest added
                info = Array(model.sorted(by: { $0.postDate > $1.postDate }).prefix(3))
            }
            return info
        }
        /// Download poster images
        dataStore.onImagesAvailable = { [self] model in
            for info in model {
                images[info.id] = dataStore.idsAndImages[info.id]
            }
            
            var entries: [TrailerEntry] = []
            // Generate a timeline consisting of three entries a day apart, starting from the current date.
            let currentDate = Date()
            for offset in 0 ..< 3 {
                let entryDate = Calendar.current.date(byAdding: .day, value: offset, to: currentDate)!
                let entry = TrailerEntry(date: entryDate, configuration: configuration, info: info[offset], image: images[info[offset].id, default: nil], dataStore: dataStore)
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct TrailerEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let info: MovieInfo
    var image: UIImage? = nil
    var dataStore: MovieInfoDataStore? = nil
}

struct TrailersWidgetEntryView : View {
    var entry: Provider.Entry
    var showsDetails: Bool
    /// Supported families are .systemMedium and .systemLarge
    @Environment(\.widgetFamily) private var family: WidgetFamily
    
    func getImage(_ info: MovieInfo) -> UIImage {
        if let i = entry.dataStore?.idsAndImages[info.id], let poster = i {
            return poster
        } else {
            return UIImage(named: "moviePosterPlaceholder")!
        }
    }
    
    var body: some View {
        GeometryReader { frame in
            ZStack {
                if showsDetails {
                    switch family {
                    case .systemLarge:
                        /// large poster, title and details
                        MoviePosterWithMetadata(info: entry.info, image: getImage(entry.info))
                    default:
                        /// small poster, title and details on the side
                        MoviePosterWithTitle(info: entry.info, image: getImage(entry.info))
                    }
                } else {
                    switch family {
                    case .systemLarge:
                        /// large poster, title and details
                        LargeMoviePosterWithTitle(info: entry.info, image: getImage(entry.info))
                    default:
                        /// medium and small size not supported
                        EmptyView()
                    }
                }
            }
            .widgetURL(URL(string: "\(MovieInfoDataStore.urlScheme)\(entry.info.id)")!)
        }
        .foregroundColor(.white).background(Color.black)
    }
}

struct DetailedTrailersWidget: Widget {
    private let kind: String = "DetailedTrailersWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            
            TrailersWidgetEntryView(entry: entry, showsDetails: true)
        }
        .configurationDisplayName("Movie Details")
        .description("See the next releasing or newest added movies, a new one every day.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct SimpleTrailersWidget: Widget {
    private let kind: String = "SimpleTrailersWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            
            TrailersWidgetEntryView(entry: entry, showsDetails: false)
        }
        .configurationDisplayName("Movie Poster")
        .description("See a new movie poster every day, from either next releasing or newest added.")
        .supportedFamilies([.systemLarge])
    }
}

@main
struct TrailersWidgets: WidgetBundle {
    var body: some Widget {
        SimpleTrailersWidget()
        DetailedTrailersWidget()
    }
}

#if DEBUG
struct TrailersWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TrailersWidgetEntryView(entry: TrailerEntry(date: Date(), configuration: ConfigurationIntent(), info: MovieInfo.Example.AQuietPlaceII), showsDetails: true)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TrailersWidgetEntryView(entry: TrailerEntry(date: Date(), configuration: ConfigurationIntent(), info: MovieInfo.Example.AQuietPlaceII), showsDetails: true)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            TrailersWidgetEntryView(entry: TrailerEntry(date: Date(), configuration: ConfigurationIntent(), info: MovieInfo.Example.AQuietPlaceII), showsDetails: false)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
#endif
