//
//  CoverFlowScrollView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 19.10.20.
//

import AVKit
import SwiftUI
import TelemetryClient

struct CoverFlowScrollView: View {
    private let scrollAnchor = UnitPoint(x: 0.5, y: 1.0)
    
    @Binding var model: [MovieInfo]
    @Binding var sortingMode: SortingMode
    @State private var centeringItem: MovieInfo? = nil
    @State private var centeredItem: MovieInfo? = nil
    @State private var playingTrailer: MovieInfo? = nil
    @State private var settingsPresented = false
    @State private var searchPresented = false
    
    @EnvironmentObject private var dataStore: MovieInfoDataStore
    @EnvironmentObject private var windowSceneObject: WindowSceneObject
    @ObservedObject private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @EnvironmentObject private var viewParameters: ViewParameters
    
    /// Animation state
    @State private var viewAnimationProgress: CGFloat = 0
    
    /// Audio Player
    @State fileprivate var audioFeedback = AudioFeedback()
        
    var body: some View {
        GeometryReader { frame in
            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { vertReader in
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                        VStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                ScrollViewReader { reader in
                                    CoverFlowListView(frame: frame, model: $model, onSelected: { (info, isCentered) in
                                        if isCentered {
                                            /// Tapped on poster that was already centered
                                            tryPlayTrailer(info)
                                        } else {
                                            withAnimation(.easeOut) {
                                                centeringItem = info
                                                reader.scrollTo(info.id, anchor: scrollAnchor)
                                            }
                                        }
                                    }, onCenteredItemChanged: { info in
                                        guard viewAnimationProgress == 1 else { return }
                                        if let info = info, centeredItem != info {
                                            /// not already centering an item, so do that now
                                            centeringItem = info
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                                if centeringItem == info {
                                                    withAnimation(.easeOut) {
                                                        reader.scrollTo(info.id, anchor: scrollAnchor)
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                        if centeringItem == info {
                                                            withAnimation(.easeIn) {
                                                                centeredItem = info
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            withAnimation(.easeOut) {
                                                centeredItem = nil
                                            }
                                        }
                                    })
                                    .onChange(of: centeredItem) { info in
                                        if let info = info {
                                            withAnimation(.easeOut) {
                                                reader.scrollTo(info.id, anchor: scrollAnchor)
                                            }
                                        }
                                    }
                                    /// Widget tapped => show trailer by id
                                    .onChange(of: viewParameters.showTrailerID ?? -1) { _ in
                                        handleShowTrailer(viewParameters.showTrailerID, reader)
                                    }
                                }
                            }
                            .offset(x: frame.size.width * (1-viewAnimationProgress), y: 0)
                            .opacity(Double(viewAnimationProgress))
                            
                            Spacer()
                        }
                        .frame(height: frame.size.height * 2)
                        .fullScreenCover(item: $playingTrailer) { info in
                            InlineTrailerPlayerView(url: info.trailerURL!, enterFullScreenOnAppear: true)
                                .modifier(CustomDarkAppearance())
                                .environmentObject(windowSceneObject)
                        }
                        
                        // back in ZStack
                        // MARK: Meta buttons
                        VStack(alignment: .trailing) {
                            HStack {
                                Button(action: {
                                    searchPresented = true
                                }, label: {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                        Text("Search")
                                    }
                                })
                                .accessibility(label: Text("Search for movies"))
                                .accessibilityHint(Text("Opens the Search popup"))
                                .sheet(isPresented: $searchPresented, content: {
                                    MovieSearchView(model: model, onSelected: { info in
                                        centeredItem = info
                                    })
                                    .modifier(CustomDarkAppearance())
                                })
                                
                                Spacer()
                                
                                Button(action: {
                                    let nextMode = sortingMode.nextMode()
                                    DispatchQueue.global(qos: .userInteractive).async {
                                        let sortedModel = model.sorted(by: nextMode.predicate)
                                        DispatchQueue.main.async {
                                            sortingMode = nextMode
                                            model = sortedModel
                                        }
                                    }
                                }, label: {
                                    HStack {
                                        Image(systemName: "arrow.up.arrow.down")
                                        Text(sortingMode.rawValue)
                                    }
                                })
                                .accessibility(label: Text("Movies are sorted by \(sortingMode.rawValue)"))
                                .accessibilityHint(Text("Tap to sort by \(sortingMode.nextMode().rawValue)"))
                                
                                Spacer()
                                
                                Button {
                                    settingsPresented = true
                                } label: {
                                    HStack {
                                        Image(systemName: "gearshape")
                                        Text("Settings")
                                    }
                                }
                                .accessibility(label: Text("Settings"))
                                .accessibilityHint(Text("Opens Settings popup"))
                                .sheet(isPresented: $settingsPresented) {
                                    SettingsView()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            // pin buttons to top
                            Spacer()
                        }
                        
                        // MARK: Movie Metadata
                        CoverFlowMovieMetaView(model: centeredItem ?? MovieInfo.Empty, onPlay: { info in
                            tryPlayTrailer(info)
                        }, onDetailsTap: { info in
                            withAnimation(.easeInOut) {
                                vertReader.scrollTo(info.id * 1024, anchor: .bottom)
                            }
                        }, onTopTap: { info in
                            withAnimation(.easeInOut) {
                                vertReader.scrollTo(info.id * 1024, anchor: .top)
                            }
                        })
                        .id((centeredItem ?? MovieInfo.Empty).id * 1024)
                        .padding(.top, frame.size.height - 128)
                        .opacity(centeredItem == nil ? 0 : 1)
                        .animation(.easeIn)
                        .onChange(of: appDelegate.isExternalScreenConnected, perform: { isExternalScreenConnected in
                            if let nowPlaying = playingTrailer, isExternalScreenConnected {
                                // screen was connected while trailer is playing, play it on external
                                withAnimation(.easeIn) {
                                    dataStore.selectedTrailerModel = nowPlaying
                                }
                                DispatchQueue.main.async {
                                    playingTrailer = nil
                                    dataStore.isPlaying = true
                                }
                            }
                        })
                        .onChange(of: dataStore.streamingAvailable, perform: { streamingAvailable in
                            if dataStore.selectedTrailerModel != nil, !appDelegate.isExternalScreenConnected, dataStore.isPlaying, playingTrailer == nil {
                                // screen was disconnected while trailer was playing
                                dataStore.selectedTrailerModel = nil
                                dataStore.isPlaying = false
                            }
                            if dataStore.isPlaying && !streamingAvailable {
                                // playing on external display and went offline
                                withAnimation {
                                    dataStore.isPlaying = false
                                    playingTrailer = nil
                                }
                            } else if playingTrailer != nil && !streamingAvailable {
                                // playing and went offline
                                withAnimation {
                                    playingTrailer = nil
                                }
                            }
                        })
                    }
                }
            }
        }
        .onAppear {
            let duration: Double = 2
            withAnimation(Animation.easeOut(duration: duration)) {
                viewAnimationProgress = 1
            }
        }
        .onChange(of: centeredItem) { centeredItem in
            if appDelegate.isExternalScreenConnected {
                withAnimation(.easeIn) {
                    dataStore.selectedTrailerModel = centeredItem
                }
            }
        }
        .onChange(of: centeringItem) { centeringItem in
            if centeringItem != nil {
                audioFeedback.selectionChange()
            }
        }
        .onChange(of: playingTrailer) { nowPlaying in
            if nowPlaying == nil {
                audioFeedback.exit()
            }
        }
    }
    
    private func tryPlayTrailer(_ info: MovieInfo) {
        if dataStore.streamingAvailable {
            audioFeedback.selection()
            if appDelegate.isExternalScreenConnected {
                dataStore.isPlaying = false
                if dataStore.selectedTrailerModel != nil && dataStore.selectedTrailerModel != info {
                    withAnimation(.easeIn) {
                        dataStore.selectedTrailerModel = nil
                    }
                }
                DispatchQueue.main.asyncAfter(0.05) {
                    withAnimation(.easeIn) {
                        dataStore.selectedTrailerModel = info
                    }
                    DispatchQueue.main.asyncAfter(0.05) {
                        dataStore.isPlaying = true
                    }
                }
                if let windowScene = windowSceneObject.windowScene {
                    AppStoreReviewsManager.requestReviewIfAppropriate(in: windowScene)
                }
            } else {
                withAnimation {
                    playingTrailer = info
                }
            }
            dataStore.setWatchedTrailer(info)
        } else {
            audioFeedback.limit()
        }
    }
    
    private func handleShowTrailer(_ movieId: Int?, _ reader: ScrollViewProxy) {
        if viewAnimationProgress != 1 {
            viewAnimationProgress = 1
        }
        if let id = movieId, let info = model.first(where: { $0.id == id }) {
            reader.scrollTo(id, anchor: scrollAnchor)
            centeredItem = info
            DispatchQueue.main.asyncAfter(0.5) {
                /// We have to set it again because the scrollView wants to center the first trailer
                /// so when the app starts cold from the widget, after returning from the player
                /// the ScrollView would have scrolled back to the first item.
                DispatchQueue.main.asyncAfter(2) {
                    centeredItem = info
                }
                withAnimation {
                    tryPlayTrailer(info)
                }
                /// telemetry data
                let data = ["trailerID":"\(info.id)", "movieTitle":info.title]
                /// send without user ID to not track anyone's watching habits
                TelemetryManager.send("widgetTapped", for: "", with: data)
            }
        }
    }
}

#if DEBUG
struct CoverFlowScrollView_Previews: PreviewProvider {
    static var previews: some View {
        CoverFlowScrollView(model: .constant([MovieInfo.Example.AQuietPlaceII]), sortingMode: .constant(.ReleaseAscending))
    }
}
#endif

// MARK: - UI Audio Feedback
fileprivate class AudioFeedback {
    private let selectAudioPlayer: AVAudioPlayer?
    private let limitAudioPlayer: AVAudioPlayer?
    private let exitAudioPlayer: AVAudioPlayer?
    private let selectionChangeAudioPlayer: AVAudioPlayer?
    
    init() {
        selectAudioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Selection", withExtension: "aif")!)
        limitAudioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Limit", withExtension: "aif")!)
        exitAudioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Exit", withExtension: "aif")!)
        selectionChangeAudioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "SelectionChange", withExtension: "aif")!)
    }
    
    private func tryPlay(_ player:AVAudioPlayer?) {
        if Settings.instance.playUISounds, let player = player {
            DispatchQueue.global(qos: .userInitiated).async {
                player.play()
            }
        }
    }
    
    public func selection() {
        tryPlay(selectAudioPlayer)
    }
    
    public func limit() {
        tryPlay(limitAudioPlayer)
    }
    
    public func exit() {
        tryPlay(exitAudioPlayer)
    }
    
    public func selectionChange() {
        tryPlay(selectionChangeAudioPlayer)
    }
}
