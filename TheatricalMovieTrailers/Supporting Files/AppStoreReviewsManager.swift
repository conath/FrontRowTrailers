//
//  AppStoreReviewManager.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 27.10.20.
//

import StoreKit

/**
 Shows the App Store review prompt if appropriate.
 Appropriate means:
 - app launched > 1 minute ago
 - has watched at least one trailer
 */
class AppStoreReviewsManager {
    static func requestReviewIfAppropriate(in windowScene: UIWindowScene) {
        let settings = Settings.instance
        // check if app was first launched more than one minute ago
        guard Date().timeIntervalSince(settings.firstLaunchedDate) > 1 * 60/* seconds */ else {
            return
        }
        // further checks, e.g. has watched at least one trailer
        
        // check that a no request for review of this app version has been made
        let currentVersion = UIApplication.shared.version
        let lastVersion = settings.lastReviewRequestAppVersion
        guard lastVersion == nil || lastVersion! != currentVersion else {
            return
        }
        
        // request for the review popup to be shown
        SKStoreReviewController.requestReview(in: windowScene)
        
        // update last requested version number
        settings.lastReviewRequestAppVersion = currentVersion
    }
}
