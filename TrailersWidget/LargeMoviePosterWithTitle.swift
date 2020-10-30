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
    @State var image: UIImage
    
    var body: some View {
        GeometryReader { frame in
            VStack(alignment: .center) {
                FramedImage(uiImage: image)
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
            .widgetURL(URL(string: "trailer://\(info.id)")!)
        }
        .foregroundColor(.white)
        .background(Color.black)
    }
}

#if DEBUG
struct LargeMoviePosterWithTitle_Previews: PreviewProvider {
    static var previews: some View {
        LargeMoviePosterWithTitle(info: MovieInfo.Example.AQuietPlaceII, image: UIImage(named: "moviePosterPlaceholder")!)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
