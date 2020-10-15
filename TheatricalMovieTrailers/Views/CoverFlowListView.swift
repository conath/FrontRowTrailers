//
//  CoverFlowListView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.10.20.
//

import SwiftUI

struct CoverFlowListView: View {
    @State var model: [MovieInfo]
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    ForEach(model) { model in
                        MoviePosterView(id: model.id)
                            .frame(width: 200)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct CoverFlowListView_Previews: PreviewProvider {
    static var previews: some View {
        CoverFlowListView(model: [MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII])
    }
}
#endif
