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
    @State private var centeringItem: MovieInfo? = nil
    @State private var centeredItem: MovieInfo? = nil
    @State private var playingTrailer: MovieInfo? = nil
    
    @ObservedObject private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
                                }
                            }
                            Spacer()
                        }
                        .frame(height: frame.size.height * 2)
                        
                        // back in ZStack
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
        .fullScreenCover(item: $playingTrailer) { info in
            TrailerPlayerView(avPlayer: .constant(AVPlayer(url: info.trailerURL!)), isPlaying: $appDelegate.isPlaying) { (player, change) in
                guard let newRate = change.newValue else { return }
                appDelegate.isPlaying = newRate > 0;
            }
            .modifier(CustomDarkAppearance())
        }
    }
    
    private func playTrailer(_ info: MovieInfo) {
        withAnimation {
            playingTrailer = info
            appDelegate.isPlaying = true
        }
    }
}

#if DEBUG
struct CoverFlowScrollView_Previews: PreviewProvider {
    static var previews: some View {
        CoverFlowScrollView(model: .constant([MovieInfo.Example.AQuietPlaceII]))
    }
}
#endif
