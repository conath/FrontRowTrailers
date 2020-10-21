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
    @State var sortingMode = SortingMode.ReleaseAscending
    
    var body: some View {
        ZStack {
            if let model = sceneDelegate.model, appDelegate.idsAndImages.count == model.count {
                MovieInfoOverView(model: model)
            }
        }
        .overlay(
            ZStack {
                if sceneDelegate.model == nil || appDelegate.idsAndImages.count != sceneDelegate.model!.count {
                    ProgressView("Loading Trailers…", value: Float(appDelegate.idsAndImages.count), total: Float(sceneDelegate.model?.count ?? 9999))
                        .frame(width: 200, height: 44)
                }
            }
            .edgesIgnoringSafeArea(.all)
        )
        .transition(.opacity)
        .modifier(CustomDarkAppearance())
        .statusBar(hidden: true)
    }
}
