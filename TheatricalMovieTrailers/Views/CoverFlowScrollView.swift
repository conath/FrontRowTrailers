//
//  CoverFlowScrollView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 19.10.20.
//

import AVKit
import SwiftUI

struct CoverFlowScrollView: View {
    @Binding var model: [MovieInfo]
    @State private var centeringItem: MovieInfo? = nil
    @State private var centeredItem: MovieInfo? = nil
    @State private var playingTrailer: MovieInfo? = nil
    
    @ObservedObject private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var body: some View {
        GeometryReader { frame in
            ScrollView(.vertical, showsIndicators: true) {
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
                                        reader.scrollTo(info.id, anchor: UnitPoint(x: 0.5, y: 1.0))
                                    }
                                }
                            }, onCenteredItemChanged: { info in
                                if let info = info, centeredItem != info {
                                    // not already centering an item, so do that now
                                    centeringItem = info
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                        if centeringItem == info {
                                            withAnimation(.easeOut) {
                                                reader.scrollTo(info.id, anchor: UnitPoint(x: 0.5, y: 1.0))
                                            }
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
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
                    // Selected Movie Info
                    if let info = centeredItem, info.trailerURL != nil {
                        CoverFlowMovieMetaView(model: info, onTap: { info in
                            playTrailer(info)
                        })
                    }
                }
            }
        }
        .fullScreenCover(item: $playingTrailer) { info in
            TrailerPlayerView(avPlayer: .constant(AVPlayer(url: info.trailerURL!)), isPlaying: $appDelegate.isPlaying) { (player, change) in
                guard let newRate = change.newValue else { return }
                appDelegate.isPlaying = newRate > 0;
            }
        }
    }
    
    private func playTrailer(_ info: MovieInfo) {
        withAnimation {
            playingTrailer = info
            appDelegate.isPlaying = true
        }
    }
}

struct CoverFlowScrollView_Previews: PreviewProvider {
    static var previews: some View {
        CoverFlowScrollView(model: .constant([MovieInfo.Example.AQuietPlaceII]))
    }
}
