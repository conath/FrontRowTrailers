//
//  AudioFeedback.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.12.21.
//

import AVKit

class AudioFeedback {
    private let selectAudioPlayer: AVAudioPlayer?
    private let limitAudioPlayer: AVAudioPlayer?
    private let exitAudioPlayer: AVAudioPlayer?
    private let selectionChangeAudioPlayer: AVAudioPlayer?
    
    init() {
        selectAudioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Selection", withExtension: "aif")!)
        limitAudioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Limit", withExtension: "aif")!)
        exitAudioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Exit", withExtension: "aif")!)
        selectionChangeAudioPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "SelectionChange", withExtension: "aif")!)
#if os(iOS)
        setAudioPriority(playingTrailer: false)
#endif
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
        selectionChangeAudioPlayer?.pause()
        selectionChangeAudioPlayer?.currentTime = 0
        tryPlay(selectionChangeAudioPlayer)
    }
    
#if os(iOS)
    public func setAudioPriority(playingTrailer: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(playingTrailer ? .playback : .ambient)
    }
#endif
}
