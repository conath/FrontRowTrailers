//
//  TrailerPlayerView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.10.20.
//

import AVKit
import SwiftUI
import UIKit

struct InlineTrailerPlayerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    typealias UIViewControllerType = AVPlayerViewController
    
    @State var avPlayer: AVPlayer
    @State var isPlaying = false
    let enterFullScreenOnAppear: Bool
    
    init(url: URL, enterFullScreenOnAppear: Bool = false) {
        _avPlayer = State<AVPlayer>(initialValue: AVPlayer(url: url))
        self.enterFullScreenOnAppear = enterFullScreenOnAppear
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<InlineTrailerPlayerView>) -> AVPlayerViewController {
        let avVC = AVPlayerViewController()
        avVC.player = avPlayer
        avVC.delegate = context.coordinator
        avVC.entersFullScreenWhenPlaybackBegins = enterFullScreenOnAppear
        avVC.exitsFullScreenWhenPlaybackEnds = true
        if enterFullScreenOnAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                /// enter full screen is private API for some reason
                avVC.enterFullScreen(animated: true)
            }
        }
        return avVC
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context:
                                    UIViewControllerRepresentableContext<InlineTrailerPlayerView>) {
        context.coordinator.trailerPlayerView = self
        if isPlaying {
            avPlayer.play()
        } else {
            avPlayer.pause()
        }
        uiViewController.player = avPlayer
    }
    
    // MARK: Coordinator is AVPlayerViewControllerDelegate
    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        var trailerPlayerView: InlineTrailerPlayerView
        
        init(_ trailerPlayerView: InlineTrailerPlayerView) {
            self.trailerPlayerView = trailerPlayerView
            super.init()
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            playerViewController.player?.play()
            trailerPlayerView.isPlaying = true
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            playerViewController.player?.pause()
            trailerPlayerView.isPlaying = false
            trailerPlayerView.presentationMode.wrappedValue.dismiss()
        }
    }
}
