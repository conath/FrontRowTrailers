//
//  TMT_MacApp.swift
//  TMT Mac
//
//  Created by Christoph Parstorfer on 20.11.21.
//

import SwiftUI
import TelemetryClient

@main
struct TMT_MacApp: App {
    let dataStore = MovieInfoDataStore.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .onAppear {
                    /// initialize telemetry
                    let configuration = TelemetryManagerConfiguration(appID: TelemetryAppId)
                    TelemetryManager.initialize(with: configuration)
                    TelemetryManager.send("appLaunchedRegularly")
                    /// put window into full screen
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
