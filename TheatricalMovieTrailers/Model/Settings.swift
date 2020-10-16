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
}

class Settings: ObservableObject {
    private let ValueAlwaysDark = 0
    private let ValueAutomaticDark = 1
    
    private static var singleton: Settings!
    static func instance() -> Settings {
        if singleton == nil {
            singleton = Settings()
        }
        return singleton
    }
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
    
    private init() {
        let defaults = UserDefaults()
        // check for version upgrade
        let lastBuild = defaults.string(forKey: .lastBuildNumber)
        if lastBuild == nil {
            defaults.setValue(UIApplication.shared.build, forKey: .lastBuildNumber)
            // set default values
            isCoverFlow = true
            prefersDarkAppearance = true
        } else if let prevBuild = lastBuild, prevBuild != UIApplication.shared.build {
            // TODO upgrade settings - depends on how old prevBuild is.
        } else {
            // load settings
            let isAutoDark = defaults.integer(forKey: .autoDark) == ValueAutomaticDark
            if isAutoDark {
                prefersDarkAppearance = false
            }
            isCoverFlow = defaults.bool(forKey: .coverFlow)
        }
    }
}
