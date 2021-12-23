//
//  TMT_MacApp.swift
//  TMT Mac
//
//  Created by Christoph Parstorfer on 20.11.21.
//

import SwiftUI

@main
struct TMT_MacApp: App {
    let dataStore = MovieInfoDataStore.shared
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(dataStore)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
