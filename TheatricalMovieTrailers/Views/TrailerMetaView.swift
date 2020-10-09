//
//  MovieMetaView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct TrailerMetaView: View {
    @Binding var model: MovieInfo!
    @State var largeTitle: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            // Title
            Text(model.title)
                .font(largeTitle ? .largeTitle : .title)
                .bold()
                .padding([.top, .trailing])
            HStack {
                // Studio
                Text(model.studio)
                    .font(largeTitle ? .title3 : .callout)
                Spacer()
                // Trailer length
                Text("Trailer: \(model.trailerLength)")
                    .font(largeTitle ? .title3 : .callout)
            }
            .padding(.bottom, 4)
        }
    }
}

#if DEBUG
struct TrailerMetaView_Previews: PreviewProvider {
    static var previews: some View {
        TrailerMetaView(model: .constant(MovieInfo.Example.AQuietPlaceII), largeTitle: false)
            .colorScheme(.dark)
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
#endif
