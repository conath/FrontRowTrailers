//
//  Settings.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 30.06.20.
//

import Foundation

class Settings: ObservableObject {
    private let DefaultsKey = "isAutoDarkAppearance"
    private let ValueAlwaysDark = 0
    private let ValueAutomaticDark = 1
    
    private static var singleton: Settings!
    static func instance() -> Settings {
        if singleton == nil {
            singleton = Settings()
        }
        return singleton
    }
    
    @Published var prefersDarkAppearance = true {
        didSet {
            let newValue = prefersDarkAppearance ? ValueAlwaysDark : ValueAutomaticDark
            let defaults = UserDefaults()
            defaults.setValue(newValue, forKey: DefaultsKey)
            defaults.synchronize()
        }
    }
    
    private init() {
        let isAutoDark = UserDefaults().integer(forKey: DefaultsKey) == ValueAutomaticDark
        if isAutoDark {
            prefersDarkAppearance = false
        }
    }
}
