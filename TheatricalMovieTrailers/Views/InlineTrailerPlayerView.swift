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
    @ObservedObject private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @EnvironmentObject private var windowSceneObject: WindowSceneObject
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, windowSceneObject)
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
        context.coordinator.windowSceneObject = windowSceneObject
        if isPlaying {
            avPlayer.play()
        } else {
            avPlayer.pause()
        }
        uiViewController.player = avPlayer
        if appDelegate.isExternalScreenConnected {
            DispatchQueue.main.async {
                uiViewController.dismiss(animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // user played trailer, request review
                    if let windowScene = windowSceneObject.windowScene {
                        AppStoreReviewsManager.requestReviewIfAppropriate(in: windowScene)
                    }
                }
            }
        }
    }
    
    // MARK: Coordinator is AVPlayerViewControllerDelegate
    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        var trailerPlayerView: InlineTrailerPlayerView
        var windowSceneObject: WindowSceneObject
        
        init(_ trailerPlayerView: InlineTrailerPlayerView, _ windowSceneObject: WindowSceneObject) {
            self.trailerPlayerView = trailerPlayerView
            self.windowSceneObject = windowSceneObject
            super.init()
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            playerViewController.player?.play()
            trailerPlayerView.isPlaying = true
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            playerViewController.player?.pause()
            trailerPlayerView.isPlaying = false
            playerViewController.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async { [self] in
                if let windowScene = windowSceneObject.windowScene {
                    AppStoreReviewsManager.requestReviewIfAppropriate(in: windowScene)
                }
            }
        }
    }
}
