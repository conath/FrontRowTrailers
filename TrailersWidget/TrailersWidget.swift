//
//  TrailersWidget.swift
//  TrailersWidget
//
//  Created by Chris on 28.10.20.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> TrailerEntry {
        TrailerEntry(date: Date(), configuration: ConfigurationIntent(), info: [MovieInfo.Empty])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (TrailerEntry) -> ()) {
        let emptyEntry = TrailerEntry(date: Date(), configuration: configuration, info: [MovieInfo.Empty])
        
        let dataStore = MovieInfoDataStore.shared
        dataStore.onMoviesAvailable = { model in
            guard let model = model else {
                completion(emptyEntry)
                return
            }
            let info: [MovieInfo]
            switch configuration.trailerScope {
            case .unknown: /// newest added
                info = Array(model.sorted(by: { $0.id > $1.id }).prefix(3))
            case .releasingSoonest:
                info = Array(model.sorted(by: SortingMode.ReleaseAscending.predicate).prefix(3))
            }
            let entry = TrailerEntry(date: Date(), configuration: configuration, info: info)
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let dataStore = MovieInfoDataStore.shared
        dataStore.onMoviesAvailable = { model in
            guard let model = model else {
                let emptyEntry = TrailerEntry(date: Date(), configuration: configuration, info: [MovieInfo.Empty])
                completion(Timeline(entries: [emptyEntry], policy: .atEnd))
                return
            }
            let info: [MovieInfo]
            switch configuration.trailerScope {
            case .unknown: /// newest added
                info = Array(model.sorted(by: { $0.id > $1.id }).prefix(3))
            case .releasingSoonest:
                info = Array(model.sorted(by: SortingMode.ReleaseAscending.predicate).prefix(3))
            }
            var entries: [TrailerEntry] = []

            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()
            for offset in 0 ..< 2 {
                let entryDate = Calendar.current.date(byAdding: .day, value: offset, to: currentDate)!
                let entry = TrailerEntry(date: entryDate, configuration: configuration, info: info, dataStore: dataStore)
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
    let info: [MovieInfo]
    var dataStore: MovieInfoDataStore? = nil
}

struct TrailersWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            ForEach(entry.info) { info in
                HStack {
                    if let i = entry.dataStore?.idsAndImages[info.id], let poster = i {
                        Image(uiImage: poster)
                    } else {
                        Image("moviePosterPlaceholder")
                    }
                    Text(info.title)
                }
            }
        }
    }
}

@main
struct TrailersWidget: Widget {
    let kind: String = "TrailersWidget"

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
            TrailersWidgetEntryView(entry: TrailerEntry(date: Date(), configuration: ConfigurationIntent(), info: [MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII]))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TrailersWidgetEntryView(entry: TrailerEntry(date: Date(), configuration: ConfigurationIntent(), info: [MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII]))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
#endif
