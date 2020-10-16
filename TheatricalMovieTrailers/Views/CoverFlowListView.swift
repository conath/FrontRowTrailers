//
//  CoverFlowListView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.10.20.
//

import SwiftUI

struct CoverFlowListView: View {
    @Binding var model: [MovieInfo]
    @State private var selectedMovie: MovieInfo? = nil
    
    var body: some View {
        GeometryReader { frame in
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { reader in
                    VStack {
                        Spacer().frame(height: frame.size.height * 0.1)
                        HStack(alignment: .center, spacing: itemWidth(frame) * -0.5) {
                            ForEach(model) { model in
                                GeometryReader { movGeo in
                                    ZStack {
                                        CoverFlowRotatingView(envGeo: frame, content:
                                            MoviePosterView(id: model.id, reflectionDistance: 0) {
                                                if isCenteredX(container: frame, movGeo) {
                                                self.selectedMovie = model
                                                } else {
                                                    withAnimation {
                                                        reader.scrollTo(model.id, anchor: .center)
                                                    }
                                                }
                                            }
                                        )
                                        Text(model.title)
                                            .font(.headline)
                                            .padding(.top, 25)
                                            .opacity(isCenteredX(container: frame, movGeo) ? 1 : 0)
                                            .animation(.easeIn)
                                    }
                                }
                                .frame(width: itemWidth(frame) * 1.5)
                                .id(model.id)
                            }
                        }
                    }
                    .padding(.horizontal, itemWidth(frame) * 0.25)
                }
            }
        }
        .sheet(item: $selectedMovie, content: { model in
            MovieTrailerView(model: .constant(model))
                .modifier(CustomDarkAppearance())
        })
        .edgesIgnoringSafeArea(.top)
    }
    
    private func itemWidth(_ geo: GeometryProxy) -> CGFloat {
        return min(geo.size.width * 0.5, 200)
    }
    
    private func isCenteredX(container frame: GeometryProxy, _ geo: GeometryProxy, allowance: CGFloat = 0.1) -> Bool {
        let outerCenter = frame.frame(in: .local).midX
        let center = geo.frame(in: .global).midX
        return abs(outerCenter - center) < frame.size.width * allowance
    }
}

#if DEBUG
struct CoverFlowListView_Previews: PreviewProvider {
    static var previews: some View {
        CoverFlowListView(model: .constant([MovieInfo.Example.AQuietPlaceII]))
    }
}
#endif
