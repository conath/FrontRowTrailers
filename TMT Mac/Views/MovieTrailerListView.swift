//
//  MovieTrailerListView.swift
//  Theatrical Trailers
//
//  Created by Christoph Parstorfer on 13.12.21.
//

import SwiftUI

struct MovieTrailerListView: View {
    @ObservedObject private var settings = Settings.instance
    @EnvironmentObject private var dataStore: MovieInfoDataStore
    
    @Binding var sortingMode: SortingMode
    @Binding var fadingOutImage: NSImage?
    @Binding var fadingInImage: NSImage?
    
    @State var selectedY: CGFloat?
    
    private var audioFeedback: AudioFeedback {
        get {
            ContentView.audioFeedback
        }
    }
    
    var frame: GeometryProxy
    
    var body: some View {
        ScrollViewReader { scroller in
                VStack(alignment: .leading) {
                    ScrollView(.vertical, showsIndicators: false) {
                    /// List of movie titles
                    ForEach($dataStore.model) { $movieInfo in
                        GeometryReader { geo in
                            Text(movieInfo.title)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .font(Font.title.bold())
                                .tag(movieInfo.id)
                                .onTapGesture {
                                    if movieInfo == dataStore.selectedTrailerModel {
                                        print("play trailer")
                                    } else {
                                        updateSelectedMovie(newSelection: movieInfo)
                                    }
                                }
                                .onChange(of: dataStore.selectedTrailerModel) { selected in
                                    if selected == movieInfo {
                                        audioFeedback.selectionChange()
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            selectedY = geo.frame(in: .global).midY
                                        }
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            scroller.scrollTo(movieInfo.id, anchor: .center)
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
                        .offset(x: 0, y: (selectedY ?? 0) - frame.size.height / 2 - 3)
                }
            }
        }
        .background(KeyEventHandling(onUpArrow: {
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
            guard let selected = dataStore.selectedTrailerModel else { return }
            let index = dataStore.model.firstIndex(of: selected)! + 1
            if index == dataStore.model.count {
                /// reached end of list
                audioFeedback.limit()
            } else {
                let nextMovieInfo = dataStore.model[index]
                updateSelectedMovie(newSelection: nextMovieInfo)
            }
        }))
    }
    
    private func updateSelectedMovie(newSelection: MovieInfo) {
        guard dataStore.selectedTrailerModel != newSelection else { return }
        withAnimation {
            if let selected = dataStore.selectedTrailerModel {
                let image = imageForMovie(selected)
                fadingOutImage = image
                fadingInImage = nil
            } else {
                fadingInImage = imageForMovie(newSelection)
            }
            dataStore.selectedTrailerModel = newSelection
        }
    }
    
    private func imageForMovie(_ movieInfo: MovieInfo) -> NSImage {
        return (dataStore.idsAndImages[movieInfo.id] ?? NSImage(named: "MoviePosterPlaceholder"))!
    }
}
