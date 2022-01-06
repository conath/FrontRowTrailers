//
//  MoviePosterView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 15.10.20.
//  Theatrical Trailers
//

import SwiftUI

struct MoviePosterView: View {
    private let filmPosterAspectRatio = CGFloat(0.7063020214)
    
    private var reflectionDistance: CGFloat
    @State private var onTap: (() -> ())?
    @Binding private var image: Image?
    @State private var blurReflection = true
    
    init(image: Binding<Image?>, reflectionDistance: CGFloat = -1.0, blurReflection: Bool = true, onTapGesture: (() -> ())? = nil) {
        self.reflectionDistance = reflectionDistance
        self._blurReflection = State<Bool>(initialValue: blurReflection)
        self._onTap = State<(() -> ())?>(initialValue: onTapGesture)
        self._image = image
    }
    
    var body: some View {
        let image = self.image ?? .moviePosterPlaceholder
        
        return GeometryReader { geo in
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: reflectionDistance) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: geo.size.height * 2 / 3)
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: geo.size.height * 2 / 3)
                        .opacity(0.7)
                        .mask(
                            Image("posterMirrorImageGradientMask")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .luminanceToAlpha()
                        )
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .blur(radius: blurReflection ? 1 : 0)
                }
                Spacer()
            }
            .onTapGesture(count: 1, perform: {
                onTap?()
            })
            .accessibilityHidden(true)
        }
    }
}

#if DEBUG
struct MoviePosterView_Previews: PreviewProvider {
    static var previews: some View {
        Color.black
            .overlay (
                MoviePosterView(image: .constant(.moviePosterPlaceholder))
                    .padding(.top, 24)
            )
    }
}
#endif
