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
    @State var image: UIImage
    
    var body: some View {
        GeometryReader { frame in
            HStack {
                FramedImage(uiImage: image)
                    .frame(maxWidth: frame.size.width / 2)
                    .aspectRatio(filmPosterAspectRatio, contentMode: .fit)
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
        MoviePosterWithTitle(info: MovieInfo.Example.AQuietPlaceII, image: UIImage(named: "moviePosterPlaceholder")!)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
