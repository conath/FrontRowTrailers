//
//  AVPlayerViewController+enterFullScreen.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 21.10.20.
//

import AVKit

/// Exposes private API to enter and exit full screen programmatically
/// https://github.com/SparkDev97/iOS14-Runtime-Headers/blob/master/Frameworks/AVKit.framework/AVPlayerViewController.h#L249
extension AVPlayerViewController {
    func enterFullScreen(animated: Bool) {
        perform(NSSelectorFromString("enterFullScreenAnimated:completionHandler:"), with: animated, with: nil)
    }
    func exitFullScreen(animated: Bool) {
        perform(NSSelectorFromString("exitFullScreenAnimated:completionHandler:"), with: animated, with: nil)
    }
}
