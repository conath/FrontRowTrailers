//
//  MovieTrailerListView.swift
//  Theatrical Trailers
//
//  Created by Christoph Parstorfer on 13.12.21.
//

import SwiftUI
import TelemetryClient

struct MovieTrailerListView: View {
    @ObservedObject private var settings = Settings.instance
    @EnvironmentObject private var dataStore: MovieInfoDataStore
    
    @Binding var sortingMode: SortingMode
    @State var onQuit: (() -> ())?
    
    @State private var selectedY: CGFloat?
    @State private var isHovering = false
    
    private let topAndBottomSpacer: CGFloat = 10
    private let scrollAnimationDuration = 0.4
    private let scrollCenterDistanceThreshold: CGFloat = 0.45
    
    private var audioFeedback: AudioFeedback {
        get {
            ContentView.audioFeedback
        }
    }
    
    var frame: GeometryProxy
    
    var body: some View {
        ScrollViewReader { scroller in
            VStack(alignment: .leading) {
                Spacer(minLength: topAndBottomSpacer)
                ScrollView(.vertical, showsIndicators: false) {
                    /// List of movie titles
                    ForEach($dataStore.model) { $movieInfo in
                        GeometryReader { geo in
                            Text(movieInfo.title)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .font(.titleGrande)
                                .tag(movieInfo.id)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment.topLeading)
                            /// select on hover over row
                                .onHover(perform: { isHovering in
                                    if !dataStore.isPlaying && isHovering && movieInfo != dataStore.selectedTrailerModel {
                                        self.isHovering = isHovering
                                        updateSelectedMovie(newSelection: movieInfo)
                                        let myY = geo.frame(in: .global).midY
                                        if abs(frame.size.height / 2 - myY) / (frame.size.height / 2) > scrollCenterDistanceThreshold {
                                            withAnimation {
                                                scroller.scrollTo(movieInfo.id, anchor: .center)
                                            }
                                        }
                                    }
                                })
                                .onChange(of: dataStore.selectedTrailerModel) { selected in
                                    if selected == movieInfo {
                                        if !isHovering {
                                            NSCursor.setHiddenUntilMouseMoves(true)
                                            withAnimation {
                                                scroller.scrollTo(movieInfo.id, anchor: .center)
                                            }
                                        } else {
                                            isHovering = false
                                        }
                                        audioFeedback.selectionChange()
                                        withAnimation(.easeOut(duration: scrollAnimationDuration)) {
                                            /// in this animation block we don't actually get the final midY (for when it finishes scrolling),
                                            /// which we would need. But we need to set the selectedY here to cause another view update
                                            selectedY = geo.frame(in: .global).midY
                                        }
                                    }
                                }
                            /// the ScrollView animates and updates the frame of the item many times
                                .onChange(of: geo.frame(in: .global).midY) { y in
                                    if movieInfo == dataStore.selectedTrailerModel {
                                        /// very short animation to keep it centered while scrolling, like in Front Row
                                        withAnimation(.easeOut(duration: 0.01)) {
                                            selectedY = geo.frame(in: .global).midY
                                        }
                                    }
                                }
                        }
                        .frame(width: 0.4*frame.size.width, height: ContentView.listItemHeight)
                    }
                }
                .overlay {
                    /// selection indicator
                    SelectionIndicator(frame: frame)
                        .offset(x: 0, y: (selectedY ?? 0) - frame.size.height / 2 - ContentView.listItemHeight * 3 / 12 - frame.safeAreaInsets.top + topAndBottomSpacer / 2)
                        .onTapGesture {
                            if let movieInfo = dataStore.selectedTrailerModel {
                                playTrailer(movieInfo)
                            }
                        }
                }
                /// have to reference sortingMode somehow, else the view won't update
                .background(sortingMode.rawValue.isEmpty ? EmptyView() : EmptyView())
            }
            Spacer(minLength: topAndBottomSpacer)
        }
        .background(KeyEventHandling(
            onEnter: {
                guard !dataStore.isPlaying else { return }
                guard let selected = dataStore.selectedTrailerModel else { return }
                playTrailer(selected)
            },
            onUpArrow: {
                guard !dataStore.isPlaying else { return }
                guard let selected = dataStore.selectedTrailerModel else { return }
                let index = dataStore.model.firstIndex(of: selected)! - 1
                if index < 0 {
                    /// reached start of list
                    audioFeedback.limit()
                } else {
                    let prevMovieInfo = dataStore.model[index]
                    updateSelectedMovie(newSelection: prevMovieInfo)
                }
            }, onDownArrow: {
                guard !dataStore.isPlaying else { return }
                guard let selected = dataStore.selectedTrailerModel else { return }
                let index = dataStore.model.firstIndex(of: selected)! + 1
                if index == dataStore.model.count {
                    /// reached end of list
                    audioFeedback.limit()
                } else {
                    let nextMovieInfo = dataStore.model[index]
                    updateSelectedMovie(newSelection: nextMovieInfo)
                }
            }, onEsc: {
                audioFeedback.exit()
                if dataStore.isPlaying {
                    withAnimation {
                        dataStore.isPlaying = false
                    }
                } else {
                    onQuit?()
                }
            }, onQuit: {
                audioFeedback.exit()
                onQuit?()
            }))
    }
    
    private func updateSelectedMovie(newSelection: MovieInfo) {
        guard dataStore.selectedTrailerModel != newSelection else { return }
        withAnimation {
            dataStore.selectedTrailerModel = newSelection
        }
    }
    
    private func imageForMovie(_ movieInfo: MovieInfo) -> Image {
        return (dataStore.idsAndImages[movieInfo.id] ?? .moviePosterPlaceholder)!
    }
    
    private func playTrailer(_ movieInfo: MovieInfo) {
        audioFeedback.selection()
        withAnimation {
            dataStore.selectedTrailerModel = movieInfo
            dataStore.isPlaying = true
        }
        dataStore.setWatchedTrailer(movieInfo)
    }
}
