//
//  MoviePosterWIthMetadata.swift
//  TrailersWidgetExtension
//
//  Created by Christoph Parstorfer on 30.10.20.
//

import SwiftUI
import WidgetKit

struct LargeMoviePosterWithTitle: View {
    private let filmPosterAspectRatio = CGFloat(0.7063020214)
    
    @State var info: MovieInfo
    @State var image: Image
    
    var body: some View {
        GeometryReader { frame in
            VStack(alignment: .center) {
                image
                    .resizable()
                    .aspectRatio(filmPosterAspectRatio, contentMode: .fit)
                    .clipped()
                
                Text(info.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Text(info.studio)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
            }
            .padding(8)
        }
        .foregroundColor(.white)
        .background(Color.black)
    }
}

#if DEBUG
struct LargeMoviePosterWithTitle_Previews: PreviewProvider {
    static var previews: some View {
        LargeMoviePosterWithTitle(info: MovieInfo.Example.AQuietPlaceII, image: Image.moviePosterPlaceholder)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
