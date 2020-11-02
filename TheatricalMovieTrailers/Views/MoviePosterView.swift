//
//  MoviePosterView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 15.10.20.
//

import SwiftUI

struct MoviePosterView: View {
    private let filmPosterAspectRatio = CGFloat(0.7063020214)
    
    @State private var reflectionDistance: CGFloat
    @State private var onTap: (() -> ())?
    @Binding private var image: UIImage?
    @State private var blurReflection = true
    
    init(image: Binding<UIImage?>, reflectionDistance: CGFloat = -1.0, blurReflection: Bool = true, onTapGesture: (() -> ())? = nil) {
        self._reflectionDistance = State<CGFloat>(initialValue: reflectionDistance)
        self._blurReflection = State<Bool>(initialValue: blurReflection)
        self._onTap = State<(() -> ())?>(initialValue: onTapGesture)
        self._image = image
    }
    
    var body: some View {
        var image: UIImage!
        if let posterImage = self.image {
            image = posterImage
            if image.isSymbolImage {
                image = posterImage.withTintColor(.white)
            }
        } else {
            image = UIImage(named: "moviePosterPlaceholder")
        }
        var fadeImage = image.cgImage!
        fadeImage = fadeImage.masking(UIImage(named: "posterMirrorImageGradientMask")!.cgImage!)!
        
        return GeometryReader { geo in
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: reflectionDistance) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: geo.size.height * 2 / 3)
                    Image(uiImage: UIImage(cgImage: fadeImage))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(0.7)
                        .frame(maxHeight: geo.size.height * 2 / 3)
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
        }
    }
}

#if DEBUG
struct MoviePosterView_Previews: PreviewProvider {
    static var previews: some View {
        Color.black
            .overlay (
                MoviePosterView(image: .constant(UIImage(named: "moviePosterPlaceholder")))
            .padding(.top, 24)
        )
    }
}
#endif
