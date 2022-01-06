//
//  MoviePosterWithTitle.swift
//  TrailersWidgetExtension
//
//  Created by Christoph Parstorfer on 30.10.20.
//

import SwiftUI
import WidgetKit

struct MoviePosterWithTitle: View {
    
    private let filmPosterAspectRatio = CGFloat(0.7063020214)
    
    @State var info: MovieInfo
    @State var image: Image
    
    var body: some View {
        GeometryReader { frame in
            HStack {
                FramedImage(image: image)
                    .aspectRatio(filmPosterAspectRatio, contentMode: .fit)
                    .frame(maxWidth: frame.size.width / 2)
                    .clipped()
                    .padding([.leading, .bottom, .top], 8)
                VStack(alignment: .leading) {
                    Text(info.studio)
                        .lineLimit(2)
                        .font(.subheadline)
                    Text(info.title)
                        .lineLimit(2)
                        .font(.headline)
                    HStack(alignment: .center, spacing: 0) {
                        Text("Director: ")
                            .font(.subheadline)
                        Text(info.director)
                            .font(.subheadline)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 2)
                    Text("Release: \(info.releaseDateString)")
                        .lineLimit(1)
                        .font(.caption)
                }
            }
        }
    }
}

#if DEBUG
struct MoviePosterWithTitle_Previews: PreviewProvider {
    static var previews: some View {
        MoviePosterWithTitle(info: MovieInfo.Example.AQuietPlaceII, image: Image.moviePosterPlaceholder)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
