//
//  MovieMetaView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct TrailerMetaView: View {
    @Binding var model: MovieInfo
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title
            Text(model.title)
                .font(.largeTitle)
                .bold()
                .padding([.top, .trailing])
                .padding(.bottom, 5)
            // Studio
            Text(model.studio)
                .font(.title)
                .padding(.bottom, 5)
            // Trailer length
            Text("Trailer: \(model.trailerLength)")
                .font(.title3)
        }
    }
}

struct TrailerMetaView_Previews: PreviewProvider {
    static var previews: some View {
        TrailerMetaView(model: .constant(MovieInfo.Example.AQuietPlaceII))
            .previewLayout(.sizeThatFits)
    }
}
