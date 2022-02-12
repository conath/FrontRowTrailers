//
//  Settings.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 30.06.20.
//

import Foundation
import AppKit

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
    
    @Published var prefersDarkAppearance = true {
        didSet {
            let newValue = prefersDarkAppearance ? ValueAlwaysDark : ValueAutomaticDark
            let defaults = Self.userDefaults
            defaults.setValue(newValue, forKey: .autoDark)
            defaults.synchronize()
        }
    }
    @Published var loadHighDefinition = true {
        didSet {
            let defaults = Self.userDefaults
            defaults.setValue(loadHighDefinition, forKey: .loadHighDefinition)
            defaults.synchronize()
        }
    }
    /// App Store Reviews Manager metadata
    private(set) var firstLaunchedDate: Date
    var lastReviewRequestAppVersion: String? = nil {
        didSet {
            let defaults = Self.userDefaults
            defaults.setValue(lastReviewRequestAppVersion, forKey: .lastReviewRequestAppVersion)
            defaults.synchronize()
        }
    }
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
            /// never launched, set default values
            defaults.setValue(Date(), forKey: .firstLaunchedDate)
            defaults.setValue(ValueAlwaysDark, forKey: .autoDark)
            defaults.setValue(lastReviewRequestAppVersion, forKey: .lastReviewRequestAppVersion)
            defaults.setValue(NSApplication.build, forKey: .lastBuildNumber)
            prefersDarkAppearance = true
            firstLaunchedDate = Date()
            defaults.setValue(Date(), forKey: .firstLaunchedDate)
            defaults.setValue(true, forKey: .playUISounds)
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
