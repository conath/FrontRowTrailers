//
//  MovieInfoContainerView.swift
//  Theatrical Trailers
//
//  Created by Christoph Parstorfer on 10.01.22.
//

import SwiftUI

struct MovieInfoContainerView: View {
    @EnvironmentObject private var dataStore: MovieInfoDataStore
    
    @State var frame: GeometryProxy
    
    @State private var animationProgress: CGFloat = 0
    
    private var heightFactor: CGFloat {
        1 - 0.4 * animationProgress
    }
    private var yOffset: CGFloat {
        animationProgress * -frame.size.height * 0.2
    }
    private var angle: CGFloat {
        10 - animationProgress * 10
    }
    
    var body: some View {
        VStack {
            /// Movie poster image views with fade out and in transition
            FadeInOutPosterView(posterImage: $dataStore.posterImage)
                .frame(height: frame.size.height * heightFactor)
                .offset(x: 0, y: yOffset)
                .rotation3DEffect(Angle(degrees: angle), axis: (x: 0, y: 0.5, z: 0))
                .onChange(of: dataStore.posterImage) { image in
                    DispatchQueue.main.asyncAfter(0.3) {
                        guard dataStore.posterImage == image else { return }
                        animationProgress = 0
                        DispatchQueue.main.asyncAfter(1.2) {
                            guard dataStore.posterImage == image else { return }
                            withAnimation(.easeInOut(duration: 0.5)) {
                                animationProgress = 1
                            }
                        }
                    }
                }
        }
    }
}
