//
//  FadeInOutPosterView.swift
//  Theatrical Trailers
//
//  Created by Christoph Parstorfer on 24.12.21.
//

import SwiftUI

struct FadeInOutPosterView: View {
    private let animationDuration: Double = 0.3
    
    @EnvironmentObject private var dataStore: MovieInfoDataStore
    @Binding var posterImage: Image?

    @State private var shownImage = Image?.none
    @State private var delayImageChange = false
    @State private var noImageOpacity: Double = 0
    
    var body: some View {
        Group {
            if delayImageChange {
                /// Invisible poster view to maintain layout size
                MoviePosterView(image: .constant(nil))
                    .opacity(0)
            } else if shownImage != nil {
                /// don't want this MoviePosterView to get `nil` passed in
                /// because then its width animates when the image is set again
                MoviePosterView(image: .constant(shownImage!))
                    .transition(.opacity)
            } else {
                /// placeholder shown if image is unavailable
                MoviePosterView(image: .constant(nil))
                    .transition(.opacity)
            }
        }
        /// fade in when view initially appears
        .onAppear(perform: {
            delayImageChange = true
        })
        /// fade out when the poster changes
        .onChange(of: posterImage) { [posterImage] newImage in
            guard posterImage != newImage else { return }
            withAnimation(.easeInOut(duration: animationDuration)) {
                delayImageChange = true
            }
        }
        /// fading out or finished fading out
        .onChange(of: delayImageChange) { newValue in
            if delayImageChange {
                DispatchQueue.main.asyncAfter(0.5) {
                    withAnimation {
                        delayImageChange = false
                    }
                }
            } else {
                withAnimation {
                    shownImage = _posterImage.wrappedValue
                }
            }
        }
    }
}

struct FadeInOutPosterView_Previews: PreviewProvider {
    static var previews: some View {
        FadeInOutPosterView(posterImage: .constant(nil))
    }
}
