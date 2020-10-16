//
//  ContentView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var settings = Settings.instance()
    @ObservedObject var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    
    var body: some View {
        ZStack {
            if let model = sceneDelegate.model, appDelegate.idsAndImages.count == model.count {
                MovieInfoOverView(model: model)
            }
            if settings.prefersDarkAppearance {
                Color.clear
            }
        }
        .overlay(
            ZStack {
                if sceneDelegate.model == nil || appDelegate.idsAndImages.count != sceneDelegate.model!.count {
                    ProgressView()
                }
            }
            .edgesIgnoringSafeArea(.all)
        )
        .transition(.opacity)
        .modifier(CustomDarkAppearance())
    }
}
