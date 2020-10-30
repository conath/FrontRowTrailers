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
                info = Array(model.sorted(by: SortingMode.ReleaseAscending.predicate).prefix(3))
            default: /// default to newest added
                info = Array(model.sorted(by: { $0.id > $1.id }).prefix(3))
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
                info = Array(model.sorted(by: SortingMode.ReleaseAscending.predicate).prefix(3))
            default: /// default to newest added
                info = Array(model.sorted(by: { $0.id > $1.id }).prefix(3))
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
    private let filmPosterAspectRatio = CGFloat(0.7063020214)
    var entry: Provider.Entry
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
        return GeometryReader { frame in
            switch family {
            case .systemLarge:
                /// large poster, title above
                VStack {
                    Text(entry.info.studio)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding([.leading,.top, .trailing])
                    Text(entry.info.title)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding([.leading,  .trailing])
                    
                    HStack(alignment: .top) {
                        FramedImage(uiImage: getImage(entry.info))
                            .frame(maxWidth: frame.size.width / 2)
                            .aspectRatio(filmPosterAspectRatio, contentMode: .fit)
                            .clipped()
                            .padding(.leading, 8)
                        
                        VStack(alignment: .leading) {
                            Text("Director")
                                .font(.headline)
                            Text(entry.info.director)
                                .lineLimit(2)
                                .font(.body)
                                .padding(.bottom, 2)
                            Text("Actors")
                                .font(.headline)
                            Text(entry.info.actors.joined(separator: ", "))
                                .lineLimit(2)
                                .font(.body)
                                .padding(.bottom, 2)
                            Text("Genre")
                                .font(.headline)
                            Text(entry.info.genres.joined(separator: ", "))
                                .lineLimit(2)
                                .font(.body)
                        }
                        .padding([.top, .trailing])
                    }
                    
                    Text("Release: \(entry.info.releaseDateString)")
                        .font(.caption)
                        .padding(.bottom)
                }
            default:
                /// small poster, title on the side
                HStack {
                    FramedImage(uiImage: getImage(entry.info))
                        .frame(maxWidth: frame.size.width / 2)
                        .aspectRatio(filmPosterAspectRatio, contentMode: .fit)
                        .clipped()
                        .padding([.leading, .bottom, .top], 8)
                    VStack(alignment: .leading) {
                        Text(entry.info.studio)
                            .lineLimit(2)
                            .font(.subheadline)
                        Text(entry.info.title)
                            .lineLimit(2)
                            .font(.headline)
                        Text("Director: \(entry.info.director)")
                            .lineLimit(2)
                            .font(.subheadline)
                            .padding(.vertical, 4)
                        Text("Release: \(entry.info.releaseDateString)")
                            .lineLimit(1)
                            .font(.caption)
                    }
                }
            }
        }
        .foregroundColor(.white).background(Color.black)
    }
}

@main
struct TrailersWidget: Widget {
    private let kind: String = "TrailersWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            
            TrailersWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Theatrical Trailers")
        .description("Shows the latest or newest added movie trailers.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#if DEBUG
struct TrailersWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TrailersWidgetEntryView(entry: TrailerEntry(date: Date(), configuration: ConfigurationIntent(), info: MovieInfo.Example.AQuietPlaceII))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TrailersWidgetEntryView(entry: TrailerEntry(date: Date(), configuration: ConfigurationIntent(), info: MovieInfo.Example.AQuietPlaceII))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
#endif
