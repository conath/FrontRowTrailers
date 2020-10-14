//
//  TrailerPlayerView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.10.20.
//

import AVKit
import SwiftUI
import UIKit

struct TrailerPlayerView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    typealias UIViewControllerType = AVPlayerViewController
    
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
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TrailerPlayerView>) -> AVPlayerViewController {
        let avVC = AVPlayerViewController()
        avVC.player = avPlayer
        avVC.delegate = context.coordinator
        avVC.entersFullScreenWhenPlaybackBegins = true
        avVC.exitsFullScreenWhenPlaybackEnds = true
        return avVC
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<TrailerPlayerView>) {
        DispatchQueue.main.async { [self] in
            keyValueObservation = avPlayer.observe(\.rate, changeHandler: changeHandler)
        }
        if isPlaying {
            avPlayer.play()
        } else {
            avPlayer.pause()
        }
        uiViewController.player = avPlayer
    }
    
    // MARK: Coordinator is AVPlayerViewControllerDelegate
    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
            false
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
            // TODO
            completionHandler(true)
        }
    }
}
