//
//  TrailerPlayerView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.10.20.
//

import AVFoundation
import AVKit
import SwiftUI

struct TrailerPlayerView: NSViewRepresentable {
    typealias NSViewType = AVPlayerView
    
    @State private var avPlayer: AVPlayer
    @Binding var isShown: Bool
    
    init(url: URL, isShown: Binding<Bool>) {
        _avPlayer = State<AVPlayer>(initialValue: AVPlayer(url: url))
        _isShown = isShown
    }
    
    func makeNSView(context: Context) -> AVPlayerView {
        let avVC = AVPlayerView()
        avVC.player = avPlayer
        avPlayer.play()
        return avVC
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        nsView.player = avPlayer
    }
}
