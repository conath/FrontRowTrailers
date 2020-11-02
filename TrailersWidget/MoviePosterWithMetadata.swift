//
//  MoviePosterWIthMetadata.swift
//  TrailersWidgetExtension
//
//  Created by Christoph Parstorfer on 30.10.20.
//

import SwiftUI
import WidgetKit

struct MoviePosterWithMetadata: View {
    private let filmPosterAspectRatio = CGFloat(0.7063020214)
    
    @State var info: MovieInfo
    @State var image: UIImage
    
    var body: some View {
        GeometryReader { frame in
            VStack {
                Text(info.studio)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding([.leading,.top, .trailing])
                Text(info.title)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding([.leading,  .trailing])
                
                HStack(alignment: .top) {
                    FramedImage(uiImage: image)
                        .frame(width: frame.size.width / 2 - 16)
                        .aspectRatio(filmPosterAspectRatio, contentMode: .fit)
                        .clipped()
                        .padding(.leading, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Director")
                            .font(.headline)
                        Text(info.director)
                            .lineLimit(2)
                            .font(.body)
                            .padding(.bottom, 2)
                        Text("Actors")
                            .font(.headline)
                        Text(info.actors.joined(separator: ", "))
                            .lineLimit(3)
                            .font(.body)
                            .padding(.bottom, 2)
                        Text("Genre")
                            .font(.headline)
                        Text(info.genres.joined(separator: ", "))
                            .lineLimit(2)
                            .font(.body)
                    }
                    .padding(.trailing, 8)
                }
                
                Text("Release: \(info.releaseDateString)")
                    .font(.caption)
                    .padding(.bottom)
            }
        }
    }
}

#if DEBUG
struct MoviePosterWithMetadata_Previews: PreviewProvider {
    static var previews: some View {
        MoviePosterWithMetadata(info: MovieInfo.Example.AQuietPlaceII, image: UIImage(named: "moviePosterPlaceholder")!)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
