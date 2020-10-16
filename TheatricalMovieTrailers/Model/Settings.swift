//
//  Settings.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 30.06.20.
//

import Foundation

fileprivate extension String {
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
    
    @Published var prefersDarkAppearance = true {
        didSet {
            let newValue = prefersDarkAppearance ? ValueAlwaysDark : ValueAutomaticDark
            let defaults = UserDefaults()
            defaults.setValue(newValue, forKey: .autoDark)
            defaults.synchronize()
        }
    }
    @Published var isCoverFlow = true {
        didSet {
            let defaults = UserDefaults()
            defaults.setValue(isCoverFlow, forKey: .coverFlow)
            defaults.synchronize()
        }
    }
    
    private init() {
        let defaults = UserDefaults()
        let isAutoDark = defaults.integer(forKey: .autoDark) == ValueAutomaticDark
        if isAutoDark {
            prefersDarkAppearance = false
        }
        isCoverFlow = defaults.bool(forKey: .coverFlow)
    }
}
