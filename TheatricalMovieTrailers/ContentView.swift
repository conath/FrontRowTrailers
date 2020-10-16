//
//  ContentView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var settings = Settings.instance()
    @EnvironmentObject var sceneDelegate: SceneDelegate
    
    var body: some View {
        ZStack {
            if sceneDelegate.model != nil {
                MovieInfoOverView(model: sceneDelegate.model)
            }
            if settings.prefersDarkAppearance {
                Group {}
            }
        }
        .overlay(
            Group {
                if sceneDelegate.model == nil {
                    ProgressView()
                }
            }
        )
        .modifier(CustomDarkAppearance())
    }
}
