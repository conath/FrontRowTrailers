//
//  ExternalView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct ExternalView: View {
    @ObservedObject private var dataStore = MovieInfoDataStore.shared
    
    var body: some View {
        GeometryReader { geo in
            if let selected = dataStore.selectedTrailerModel {
                ExternalTrailerView(model: selected, posterImage: $dataStore.posterImage)
            } else {
                Text("No trailer selected")
                    .font(.largeTitle)
                    .bold()
                    .padding()
            }
        }
        .background(Color.black)
        .colorScheme(.dark)
    }
}
