//
//  MovieInfoContainerView.swift
//  Theatrical Trailers
//
//  Created by Christoph Parstorfer on 10.01.22.
//

import SwiftUI

struct MovieInfoContainerView: View {
    @EnvironmentObject private var dataStore: MovieInfoDataStore
    
    var body: some View {
        /// Movie poster image views with fade out and in transition
        FadeInOutPosterView(posterImage: $dataStore.posterImage)
    }
}
