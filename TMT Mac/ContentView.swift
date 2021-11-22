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
    @State private var selectedY: CGFloat?
    
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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        /// List of movie titles
                        ForEach($dataStore.model) { $movieInfo in
                            GeometryReader { geo in
                                Text(movieInfo.title)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .font(Font.title.bold())
                                    .onTapGesture {
                                        if movieInfo == dataStore.selectedTrailerModel {
                                            print("play trailer")
                                        } else {
                                            withAnimation {
                                                if let selected = dataStore.selectedTrailerModel {
                                                    let image = imageForMovie(selected)
                                                    fadingOutImage = image
                                                    fadingInImage = nil
                                                } else {
                                                    fadingInImage = imageForMovie(movieInfo)
                                                }
                                                dataStore.selectedTrailerModel = movieInfo
                                            }
                                        }
                                    }
                                    .onChange(of: dataStore.selectedTrailerModel) { selected in
                                        if selected == movieInfo {
                                            withAnimation(.easeOut) {
                                                selectedY = geo.frame(in: .global).midY
                                            }
                                        }
                                    }
                            }
                            .frame(width: 0.4*frame.size.width, height: ContentView.listItemHeight)
                        }
                    }
                }
                .overlay {
                    /// selection indicator
                    Text("Layout placeholder")
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.clear)
                        .accessibilityHidden(true)
                        .font(Font.title.bold())
                        .frame(width: 0.4*frame.size.width, height: ContentView.selectionRectHeight)
                        .padding(15)
                        .background(
                            ZStack(alignment: .leading) {
                                /// blue shine
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .border(Color.blue, width: 10)
                                    .blur(radius: 4)
                                    .padding(4)
                                    .mask {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .border(Color.white, width: 7)
                                    }
                                /// black border
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .border(Color.black, width: 2)
                                    .padding(6)
                                /// gloss shine
                                Rectangle()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .foregroundColor(.clear)
                                    .overlay(
                                        LinearGradient(colors: [.init(white: 1, opacity: 0.5), .init(white: 1, opacity: 0.2), .clear, .clear, .clear, .clear], startPoint: .top, endPoint: .bottom))
                                    .padding(8)
                            }
                                .frame(height: ContentView.selectionRectHeight)
                        )
                        .offset(x: 0, y: (selectedY ?? 0) - frame.size.height / 2 - 3)
                }
            }
        }
        //        CoverFlowScrollView(model: $dataStore.model, sortingMode: $sortingMode)
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
        })
    }
    
    private func imageForMovie(_ movieInfo: MovieInfo) -> NSImage {
        return (dataStore.idsAndImages[movieInfo.id] ?? NSImage(named: "MoviePosterPlaceholder"))!
    }
}
