//
//  ContentView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sceneDelegate: SceneDelegate
    
    var body: some View {
            ZStack {
                if sceneDelegate.model != nil {
                    TrailerListView(model: sceneDelegate.model)
                }
            }
            .overlay(
                Group {
                    if sceneDelegate.model == nil {
                        ProgressView()
                    }
                }
                .background(Color.black)
            )
            .colorScheme(.dark)
    }
}
