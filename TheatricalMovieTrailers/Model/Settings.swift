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
    static let coverFlow = "isCoverFlow"
    static let loadHighDefinition = "loadHighDefinition"
    static let firstLaunchedDate = "firstLaunchedDate"
    static let lastReviewRequestAppVersion = "lastReviewRequestAppVersion"
}

class Settings: ObservableObject {
    private let ValueAlwaysDark = 0
    private let ValueAutomaticDark = 1
    
    static let instance = Settings()
    
    // Present since the beginning
    @Published var prefersDarkAppearance = true {
        didSet {
            let newValue = prefersDarkAppearance ? ValueAlwaysDark : ValueAutomaticDark
            let defaults = UserDefaults()
            defaults.setValue(newValue, forKey: .autoDark)
            defaults.synchronize()
        }
    }
    // Added in Build 22
    @Published var isCoverFlow = true {
        didSet {
            let defaults = UserDefaults()
            defaults.setValue(isCoverFlow, forKey: .coverFlow)
            defaults.synchronize()
        }
    }
    // Added in Build 27
    @Published var loadHighDefinition = true {
        didSet {
            let defaults = UserDefaults()
            defaults.setValue(loadHighDefinition, forKey: .loadHighDefinition)
            defaults.synchronize()
        }
    }
    /// Added in Build 30
    /// App Store Reviews Manager metadata
    let firstLaunchedDate: Date
    var lastReviewRequestAppVersion: String? = nil {
        didSet {
            let defaults = UserDefaults()
            defaults.setValue(lastReviewRequestAppVersion, forKey: .lastReviewRequestAppVersion)
            defaults.synchronize()
        }
    }
    
    private init() {
        let defaults = UserDefaults()
        // check for version upgrade
        let lastBuild = defaults.string(forKey: .lastBuildNumber)
        if lastBuild == nil {
            defaults.setValue(UIApplication.shared.build, forKey: .lastBuildNumber)
            // set default values
            isCoverFlow = true
            prefersDarkAppearance = true
            firstLaunchedDate = Date()
            defaults.setValue(Date(), forKey: .firstLaunchedDate)
        } else if let prevBuild = lastBuild, prevBuild != UIApplication.shared.build {
            if Int(prevBuild)! < 30 {
                firstLaunchedDate = Date()
                defaults.setValue(firstLaunchedDate, forKey: .firstLaunchedDate)
            } else {
                firstLaunchedDate = defaults.value(forKey: .firstLaunchedDate) as! Date
            }
        } else {
            // load settings
            let isAutoDark = defaults.integer(forKey: .autoDark) == ValueAutomaticDark
            if isAutoDark {
                prefersDarkAppearance = false
            }
            isCoverFlow = defaults.bool(forKey: .coverFlow)
            /// App Store Reviews Manager metadata
            firstLaunchedDate = defaults.value(forKey: .firstLaunchedDate) as! Date
            lastReviewRequestAppVersion = defaults.string(forKey: .lastReviewRequestAppVersion)
        }
    }
}
