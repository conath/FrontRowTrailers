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
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    typealias NSViewType = AVPlayerView
    
    @Binding var avPlayer: AVPlayer
    @Binding var isPlaying: Bool
    
    @State private var keyValueObservation: NSKeyValueObservation
    @State private var changeHandler: ((AVPlayer, NSKeyValueObservedChange<Float>) -> ())
    
    init(avPlayer: Binding<AVPlayer>, isPlaying: Binding<Bool>, avPlayerRateChangeHandler changeHandler: @escaping ((AVPlayer, NSKeyValueObservedChange<Float>) -> ())) {
        _avPlayer = avPlayer
        _isPlaying = isPlaying
        _changeHandler = State<((AVPlayer, NSKeyValueObservedChange<Float>) -> ())>(initialValue: changeHandler)
        _keyValueObservation = State<NSKeyValueObservation>(initialValue: avPlayer.wrappedValue.observe(\.rate, changeHandler: changeHandler))
    }
    
    func makeNSView(context: Context) -> AVPlayerView {
        let avVC = AVPlayerView()
        avVC.player = avPlayer
        avVC.delegate = context.coordinator
        return avVC
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        context.coordinator.trailerPlayerView = self
        DispatchQueue.main.async { [self] in
            keyValueObservation = avPlayer.observe(\.rate, changeHandler: changeHandler)
        }
        if isPlaying {
            avPlayer.play()
        } else {
            avPlayer.pause()
        }
        nsView.player = avPlayer
    }
    
    // MARK: Coordinator is AVPlayerViewDelegate
    class Coordinator: NSObject, AVPlayerViewDelegate {
        var trailerPlayerView: TrailerPlayerView
        
        init(_ trailerPlayerView: TrailerPlayerView) {
            self.trailerPlayerView = trailerPlayerView
            super.init()
        }
        
        func playerViewDidExitFullScreen(_ playerView: AVPlayerView) {
            trailerPlayerView.presentationMode.wrappedValue.dismiss()
        }
    }
}
