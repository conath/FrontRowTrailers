//
//  CoverFlowMovieMetaView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 16.10.20.
//

import SwiftUI

struct CoverFlowMovieMetaView: View {
    @State var model: MovieInfo
//    @State var movGeo: GeometryProxy
    @State var onTap: ((MovieInfo) -> ())
    
    var body: some View {
        VStack {
//            MovieMetaRow(title: "Director", value: model.director, labelWidth: movGeo.size.width / 3)
//            if let genre = model.genres.first {
//                MovieMetaRow(title: "Genre", value: genre, labelWidth: movGeo.size.width / 3)
//            }
//            MovieMetaRow(title: "Release", value: model.releaseDateString, labelWidth: movGeo.size.width / 3)
            
            Button(action: {
                onTap(model)
            }, label: {
                    HStack {
                        Image(systemName: "play.fill")
                            .foregroundColor(.primary)
                            .padding(.leading)
                        Text("Watch Trailer")
                            .foregroundColor(.primary)
                            .padding([.top, .bottom, .trailing])
                    }
                    .background (
                        RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    )
            })
            .padding(.bottom, 16)
            Spacer()
            Text(model.copyright)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }
}
