//
//  CoverFlowListView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.10.20.
//

import SwiftUI

struct CoverFlowListView: View {
    @Binding var model: [MovieInfo]
    
    var body: some View {
        /// Insert spacer at front and back of list to make sure the first and last movie poster is centered in the view
        var displayModel: [MovieInfo] = [.Empty]
        displayModel.append(contentsOf: model)
        displayModel.append(.Empty)
        
        return GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: true) {
                VStack {
                    Spacer().frame(height: geo.size.height * 0.1)
                    HStack(alignment: .center, spacing: itemWidth(geo) * -0.5) {
                        ForEach(displayModel) { model in
                            if model.id > -1 {
                                CoverFlowRotatingView(envGeo: geo, content:
                                                        MoviePosterView(id: model.id, reflectionDistance: 0)
                                )
                                .frame(width: itemWidth(geo) * 1.5)
                            } else {
                                // spacer at the front
                                Color.clear
                                    .frame(width: itemWidth(geo) * 0.75)
                            }
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
    
    private func itemWidth(_ geo: GeometryProxy) -> CGFloat {
        return min(geo.size.width * 0.5, 200)
    }
}

#if DEBUG
struct CoverFlowListView_Previews: PreviewProvider {
    static var previews: some View {
        CoverFlowListView(model: .constant([MovieInfo.Example.AQuietPlaceII]))
    }
}
#endif
