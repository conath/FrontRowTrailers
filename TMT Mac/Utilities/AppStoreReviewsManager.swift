//
//  AppStoreReviewManager.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 20.02.22.
//

import StoreKit

/**
 Shows the App Store review prompt if appropriate.
 Appropriate means:
 - app launched > 1 minute ago
 - has not been asked to review this version
 */
class AppStoreReviewsManager {
    static func requestReviewIfAppropriate() {
        let settings = Settings.instance
        // check if app was first launched more than one minute ago
        guard Date().timeIntervalSince(settings.firstLaunchedDate) > 1 * 60/* seconds */ else {
            return
        }
        
        // check that no request for review of this app version has been made
        let currentVersion = NSApplication.version
        let lastVersion = settings.lastReviewRequestAppVersion
        guard lastVersion == nil || lastVersion! != currentVersion else {
            return
        }
        
        // request for the review popup to be shown
        SKStoreReviewController.requestReview()
        
        // update last requested version number
        settings.lastReviewRequestAppVersion = currentVersion
    }
}
