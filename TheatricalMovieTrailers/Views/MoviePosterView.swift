//
//  MoviePosterView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 15.10.20.
//

import SwiftUI

struct MoviePosterView: View {
    private let filmPosterAspectRatio = CGFloat(0.7063020214)
    @ObservedObject private var dataStore = MovieInfoDataStore.shared
    
    @State private var id: Int?
    @State private var reflectionDistance: CGFloat
    @State private var onTap: (() -> ())?
    @State private var image: UIImage? = nil
    
    init(id: Int? = nil, reflectionDistance: CGFloat = -1.0, onTapGesture: (() -> ())? = nil) {
        self._id = State<Int?>(initialValue: id)
        self._reflectionDistance = State<CGFloat>(initialValue: reflectionDistance)
        self._onTap = State<(() -> ())?>(initialValue: onTapGesture)
    }
    
    init(id: Int? = nil, image: UIImage?, reflectionDistance: CGFloat = -1.0, onTapGesture: (() -> ())? = nil) {
        self._id = State<Int?>(initialValue: id)
        self._reflectionDistance = State<CGFloat>(initialValue: reflectionDistance)
        self._onTap = State<(() -> ())?>(initialValue: onTapGesture)
        self._image = State<UIImage?>(initialValue: image)
    }
    
    var body: some View {
        var image: UIImage!
        if let posterImage = self.image {
            image = posterImage
            if image.isSymbolImage {
                image = posterImage.withTintColor(.white)
            }
        } else if let id = id, let maybe = dataStore.idsAndImages[id], let posterImage = maybe {
            image = posterImage
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
                        .blur(radius: 1)
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
                MoviePosterView(id: MovieInfo.Example.AQuietPlaceII.id, image: UIImage(named: "moviePosterPlaceholder"))
            .padding(.top, 24)
        )
    }
}
#endif
