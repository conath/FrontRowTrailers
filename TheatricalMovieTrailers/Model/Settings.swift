//
//  Settings.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 30.06.20.
//

import Foundation
import UIKit

fileprivate extension String {
    static let lastBuildNumber = "lastBuildNumber"
    static let autoDark = "isAutoDarkAppearance"
    static let loadHighDefinition = "loadHighDefinition"
    static let firstLaunchedDate = "firstLaunchedDate"
    static let lastReviewRequestAppVersion = "lastReviewRequestAppVersion"
    static let playUISounds = "playUISounds"
}

class Settings: ObservableObject {
    private let ValueAlwaysDark = 0
    private let ValueAutomaticDark = 1
    
    static let instance = Settings()
    
    static var userDefaults: UserDefaults {
        return UserDefaults(suiteName: "cafe.chrisp.tmt.settings")!
    }
    
    // Present since the beginning
    @Published var prefersDarkAppearance = true {
        didSet {
            let newValue = prefersDarkAppearance ? ValueAlwaysDark : ValueAutomaticDark
            let defaults = Self.userDefaults
            defaults.setValue(newValue, forKey: .autoDark)
            defaults.synchronize()
        }
    }
    // Added in Build 27
    @Published var loadHighDefinition = true {
        didSet {
            let defaults = Self.userDefaults
            defaults.setValue(loadHighDefinition, forKey: .loadHighDefinition)
            defaults.synchronize()
        }
    }
    /// Added in Build 30
    /// App Store Reviews Manager metadata
    private(set) var firstLaunchedDate: Date
    var lastReviewRequestAppVersion: String? = nil {
        didSet {
            let defaults = Self.userDefaults
            defaults.setValue(lastReviewRequestAppVersion, forKey: .lastReviewRequestAppVersion)
            defaults.synchronize()
        }
    }
    /// Added in Build 40
    /// Whether to play FrontRow-inspired UI sounds
    @Published var playUISounds = true {
        didSet {
            let defaults = Self.userDefaults
            defaults.setValue(playUISounds, forKey: .playUISounds)
            defaults.synchronize()
        }
    }
    
    private init() {
        let defaults = Self.userDefaults
        /// Check for version upgrade
        let lastBuild = defaults.string(forKey: .lastBuildNumber)
        if lastBuild == nil {
            let oldDefaults = UserDefaults()
            let oldBuild = oldDefaults.string(forKey: .lastBuildNumber)
            if let old = oldBuild, let oldNumber = Int(old) {
                if oldNumber < 30 {
                    firstLaunchedDate = Date()
                    defaults.setValue(firstLaunchedDate, forKey: .firstLaunchedDate)
                } else {
                    firstLaunchedDate = oldDefaults.value(forKey: .firstLaunchedDate) as! Date
                }
            }
            /// If last build is older than 30, that used non-specific UserDefaults suite. Must migrate!
            if oldDefaults.string(forKey: .lastBuildNumber) == "31" {
                /// Migrate settings to new defaults suite
                let isAutoDark = oldDefaults.integer(forKey: .autoDark) == ValueAutomaticDark
                if isAutoDark {
                    prefersDarkAppearance = false
                }
                firstLaunchedDate = oldDefaults.value(forKey: .firstLaunchedDate) as! Date
                lastReviewRequestAppVersion = oldDefaults.string(forKey: .lastReviewRequestAppVersion)
                defaults.setValue(firstLaunchedDate, forKey: .firstLaunchedDate)
                defaults.setValue(isAutoDark, forKey: .autoDark)
                defaults.setValue(lastReviewRequestAppVersion, forKey: .lastReviewRequestAppVersion)
                defaults.setValue(UIApplication.build, forKey: .lastBuildNumber)
            } else {
                /// New install
                defaults.setValue(UIApplication.build, forKey: .lastBuildNumber)
                /// Set default values
                prefersDarkAppearance = true
                firstLaunchedDate = Date()
                defaults.setValue(Date(), forKey: .firstLaunchedDate)
            }
        } else if let prevBuild = lastBuild, prevBuild != UIApplication.build {
            let prevBuild = Int(prevBuild)!
            /// Version upgrade happened
            /// Upgrade from older to 40
            if prevBuild < 40 {
                /// Added playUISounds key; default value should be true but it's false for a boolean
                defaults.setValue(true, forKey: .playUISounds)
            }
            defaults.setValue(UIApplication.build, forKey: .lastBuildNumber)
        }
        /// Load settings
        let isAutoDark = defaults.integer(forKey: .autoDark) == ValueAutomaticDark
        if isAutoDark {
            prefersDarkAppearance = false
        }
        /// App Store Reviews Manager metadata
        firstLaunchedDate = defaults.value(forKey: .firstLaunchedDate) as! Date
        lastReviewRequestAppVersion = defaults.string(forKey: .lastReviewRequestAppVersion)
        /// UI Sounds
        playUISounds = defaults.bool(forKey: .playUISounds)
    }
}
