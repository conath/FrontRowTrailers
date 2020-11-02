//
//  CoverFlowListView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.10.20.
//

import SwiftUI

struct CoverFlowListView: View {
    @State var frame: GeometryProxy
    @Binding var model: [MovieInfo]
    @State var onSelected: (MovieInfo, Bool) -> ()
    @State var onCenteredItemChanged: (MovieInfo?) -> ()
    
    var body: some View {
        VStack {
            Spacer().frame(height: frame.size.height * 0.1)
            HStack(alignment: .center, spacing: itemWidth(frame) * -0.5) {
                Spacer()
                    .frame(width: frame.size.width * 0.2, height: 100)
                ForEach(model) { info in
                    CoverFlowItemView(frame: frame, model: info, onSelected: { (isCentered: Bool) in
                        onSelected(info, isCentered)
                    }, onCentered: { isCentered in
                        onCenteredItemChanged(isCentered ? info : nil)
                    })
                    .frame(width: itemWidth(frame) * 1.5, height: frame.size.height * 0.8)
                    .id(info.id)
                }
                Spacer()
                    .frame(width: frame.size.width * 0.2, height: 100)
            }
            .padding(.horizontal, frame.size.width * 0.25)
        }
    }
    
    private func itemWidth(_ geo: GeometryProxy) -> CGFloat {
        return min(geo.size.width * 0.5, 300)
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
        GeometryReader { frame in
            CoverFlowListView(frame: frame, model: .constant([MovieInfo.Example.AQuietPlaceII]), onSelected: { _,_  in }, onCenteredItemChanged: { _ in })
        }
    }
}
#endif
