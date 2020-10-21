//
//  CoverFlowScrollView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 19.10.20.
//

import AVKit
import SwiftUI

struct CoverFlowScrollView: View {
    private let scrollAnchor = UnitPoint(x: 0.5, y: 1.0)
    
    @Binding var model: [MovieInfo]
    @Binding var sortingMode: SortingMode
    @State private var centeringItem: MovieInfo? = nil
    @State private var centeredItem: MovieInfo? = nil
    @State private var playingTrailer: MovieInfo? = nil
    @State private var settingsPresented = false
    @State private var searchPresented = false
        
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
                                            // Tapped on poster that was already centered
                                            playTrailer(info)
                                        } else {
                                            withAnimation(.easeOut) {
                                                centeringItem = info
                                                reader.scrollTo(info.id, anchor: scrollAnchor)
                                            }
                                        }
                                    }, onCenteredItemChanged: { info in
                                        if let info = info, centeredItem != info {
                                            // not already centering an item, so do that now
                                            centeringItem = info
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                                if centeringItem == info {
                                                    withAnimation(.easeOut) {
                                                        reader.scrollTo(info.id, anchor: scrollAnchor)
                                                    }
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                    if centeringItem == info {
                                                        withAnimation(.easeIn) {
                                                            centeredItem = info
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
                                    // onChange doesn't do optionals D:
                                    .onChange(of: centeredItem ?? MovieInfo.Empty) { info in
                                        if centeredItem != nil {
                                            reader.scrollTo(info.id, anchor: scrollAnchor)
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .frame(height: frame.size.height * 2)
                        .fullScreenCover(item: $playingTrailer) { info in
                            InlineTrailerPlayerView(url: info.trailerURL!, enterFullScreenOnAppear: true)
                                .modifier(CustomDarkAppearance())
                        }
                        
                        // back in ZStack
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
                                .sheet(isPresented: $searchPresented, content: {
                                    MovieSearchView(model: model, onSelected: { info in
                                        withAnimation {
                                            centeredItem = info
                                        }
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
                                
                                Spacer()
                                
                                Button {
                                    settingsPresented = true
                                } label: {
                                    HStack {
                                        Image(systemName: "gearshape")
                                            .accessibility(label: Text("Settings"))
                                        Text("Settings")
                                    }
                                }
                                .sheet(isPresented: $settingsPresented) {
                                    SettingsView(isPresented: $settingsPresented)
                                }
                            }.padding()
                            // pin buttons to top
                            Spacer()
                        }
                        
                        // Movie Metadata
                        if let info = centeredItem, info.trailerURL != nil {
                            CoverFlowMovieMetaView(model: centeredItem ?? MovieInfo.Empty, onTap: { info in
                                playTrailer(info)
                            }, onDetailsTap: { info in
                                withAnimation(.easeInOut) {
                                    vertReader.scrollTo(info.id * 1024, anchor: .bottom)
                                }
                            }, onTopTap: { info in
                                withAnimation(.easeInOut) {
                                    vertReader.scrollTo(info.id * 1024, anchor: .top)
                                }
                            })
                            .id(info.id * 1024)
                            .padding(.top, frame.size.height * 0.8)
                        }
                    }
                }
            }
        }
        .onAppear {
            centeredItem = model.first
        }
    }
    
    private func playTrailer(_ info: MovieInfo) {
        withAnimation {
            playingTrailer = info
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
