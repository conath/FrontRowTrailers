//
//  ContentView.swift
//  TMT Mac
//
//  Created by Christoph Parstorfer on 20.11.21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var settings = Settings.instance
    @EnvironmentObject var dataStore: MovieInfoDataStore
    @State var sortingMode = SortingMode.ReleaseAscending
    @State private var loading = false
    
    @State private var fadingOutImage: NSImage?
    @State private var fadingInImage: NSImage?
    
    static let audioFeedback = AudioFeedback()
    
    static var listItemHeight: CGFloat {
        NSFont.preferredFont(forTextStyle: .title1).pointSize * 1.5
    }
    
    static var selectionRectHeight: CGFloat {
        listItemHeight * 1.5
    }
    
    static var selectionRectDeltaY: CGFloat {
        selectionRectHeight / ((selectionRectHeight / listItemHeight) * 1.5)
    }
    
    var body: some View {
        GeometryReader { frame in
            HStack {
                /// Movie poster image views with fade out and in transition
                ZStack {
                    if fadingOutImage != nil {
                        Image(nsImage: fadingOutImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: frame.size.width * 0.3)
                            .transition(.asymmetric(insertion: .identity, removal: .opacity))
                            .onAppear {
                                withAnimation {
                                    fadingOutImage = nil
                                }
                                if let selected = dataStore.selectedTrailerModel {
                                    withAnimation(.default.delay(0.7)) {
                                        fadingInImage = imageForMovie(selected)
                                    }
                                }
                            }
                    }
                    if fadingInImage != nil {
                        Image(nsImage: fadingInImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: frame.size.width * 0.3)
                            .transition(.asymmetric(insertion: .opacity, removal: .identity))
                    }
                }
                .frame(width: 0.5*frame.size.width)
                .frame(maxHeight: .infinity)
                /// Movie titles and selection overlay
                MovieTrailerListView(sortingMode: $sortingMode, fadingOutImage: $fadingOutImage, fadingInImage: $fadingInImage, frame: frame)
            }
        }
        /// loading overlay
        .overlay(
            Group {
                if loading {
                    ZStack {
                        ProgressView("Loading Trailers…")
                            .frame(width: 200, height: 44)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.init(NSColor.windowBackgroundColor))
                }
            }
        )
        .alert(item: $dataStore.error, content: { error  -> Alert in
            error.makeAlert()
        })
        .transition(.opacity)
        .modifier(CustomDarkAppearance())
        .onChange(of: sortingMode) { sortingMode in
            dataStore.model.sort(by: sortingMode.predicate)
        }
        .onAppear {
            if !dataStore.moviesAvailable {
                DispatchQueue.main.asyncAfter(0.5) {
                    if !dataStore.moviesAvailable {
                        withAnimation {
                            loading = true
                        }
                    }
                }
            }
        }
        .onChange(of: dataStore.moviesAvailable, perform: { moviesAvailable in
            withAnimation {
                loading = !moviesAvailable
            }
            if moviesAvailable {
                dataStore.model.sort(by: sortingMode.predicate)
                DispatchQueue.main.asyncAfter(0.2) {
                    if let first = dataStore.model.first {
                        withAnimation {
                            dataStore.selectedTrailerModel = first
                            fadingInImage = imageForMovie(first)
                        }
                    }
                }
            }
        })
    }
    
    private func imageForMovie(_ movieInfo: MovieInfo) -> NSImage {
        return (dataStore.idsAndImages[movieInfo.id] ?? NSImage(named: "MoviePosterPlaceholder"))!
    }
}
