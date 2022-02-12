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
            ContentView()
                .environmentObject(dataStore)
                .onAppear {
                    DispatchQueue.main.asyncAfter(0.1) {
                        if let window = NSApplication.shared.windows.last {
                            window.toggleFullScreen(nil)
                            /// give it a moment
                            DispatchQueue.main.asyncAfter(0.1) {
                                let swiftUIWindow = NSApplication.shared.windows[0]
                                swiftUIWindow.becomeKey()
                            }
                        }
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
