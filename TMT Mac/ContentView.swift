//
//  ContentView.swift
//  TMT Mac
//
//  Created by Christoph Parstorfer on 20.11.21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var settings = Settings.instance
    @EnvironmentObject private var dataStore: MovieInfoDataStore
    @State private var sortingMode = SortingMode.ReleaseAscending
    @State private var loading = false
    @State private var fadeInOut = true
    
    @State private var fadingOutImage: Image?
    @State private var fadingInImage: Image?
    
    private let fadeDuration = 1.0
    
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
                MovieInfoContainerView(frame: frame)
                    .frame(width: 0.5*frame.size.width)
                /// Movie titles and selection overlay
                MovieTrailerListView(sortingMode: $sortingMode, onQuit: {
                    withAnimation(.easeIn(duration: fadeDuration)) {
                        self.fadeInOut = true
                    }
                    DispatchQueue.main.asyncAfter(fadeDuration) {
                        NSApplication.shared.terminate(self)
                    }
                }, frame: frame)
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
                if fadeInOut {
                    ZStack {}
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .transition(.opacity)
                }
                if dataStore.isPlaying, dataStore.selectedTrailerModel?.trailerURL != nil {
                    ZStack {
                        TrailerPlayerView(url: dataStore.selectedTrailerModel!.trailerURL!, isShown: $dataStore.isPlaying)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .transition(.opacity)
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
                    withAnimation(.easeIn(duration: fadeDuration)) {
                        self.fadeInOut = false
                    }
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
            
            withAnimation(.easeIn(duration: fadeDuration)) {
                self.fadeInOut = false
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
    
    private func imageForMovie(_ movieInfo: MovieInfo) -> Image {
        return (dataStore.idsAndImages[movieInfo.id] ?? .moviePosterPlaceholder)!
    }
}
