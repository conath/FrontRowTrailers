//
//  CoverFlowListItem.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 19.10.20.
//

import SwiftUI

struct CoverFlowItemView: View {
    @State var frame: GeometryProxy
    @State var model: MovieInfo
    @State var onSelected: (Bool) -> ()
    @State var onCentered: (Bool) -> ()
    @State var isCentered = false
    @EnvironmentObject private var dataStore: MovieInfoDataStore
    @State private var image: UIImage? = nil
    
    var body: some View {
        GeometryReader { movGeo in
            ZStack {
                CoverFlowRotatingView(envGeo: frame, content:
                    MoviePosterView(image: $image) {
                        onSelected(isCentered)
                    }
                )
                VStack {
                    Spacer()
                        .frame(height: movGeo.size.height / 2)
                    
                    Spacer()
                    
                    Text(model.title)
                        .font(.title)
                        .lineLimit(4)
                        .multilineTextAlignment(.center)
                        .padding(.init(top: 0, leading: 16, bottom: 32, trailing: 16))
                    
                    Spacer()
                }
                .opacity(isCenteredX(container: frame, movGeo) ? 1 : 0)
                .animation(Animation.easeIn)
            }
            .onChange(of: movGeo.frame(in: .global).midX) { (midX) in
                if isCenteredX(container: frame, movGeo) {
                    // centered now
                    if !isCentered {
                        // moved to center
                        onCentered(true)
                        isCentered = true
                    }
                } else {
                    // off center now
                    if isCentered {
                        // moved off center
                        onCentered(false)
                        isCentered = false
                    }
                }
            }
            .onChange(of: dataStore.imagesAvailable, perform: { _ in
                DispatchQueue.main.async {
                    self.image = dataStore.idsAndImages[model.id, default: nil]
                }
            })
        }
    }
    
    private func isCenteredX(container frame: GeometryProxy, _ geo: GeometryProxy, allowance: CGFloat = 0.1) -> Bool {
        let outerCenter = frame.frame(in: .local).midX
        let center = geo.frame(in: .global).midX
        return abs(outerCenter - center) < frame.size.width * allowance
    }
}
