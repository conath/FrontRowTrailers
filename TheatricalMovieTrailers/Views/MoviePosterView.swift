//
//  MoviePosterView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 15.10.20.
//

import SwiftUI

struct MoviePosterView: View {
    private let filmPosterAspectRatio = CGFloat(0.7063020214)
    @ObservedObject private var appDelegate: AppDelegate
    
    @State var id: Int
    @State var reflectionDistance: CGFloat
    @State private var image: UIImage? = nil
    
    init(id: Int, reflectionDistance: CGFloat = 20.0) {
        self._id = State<Int>(initialValue: id)
        self._reflectionDistance = State<CGFloat>(initialValue: reflectionDistance)
        appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    #if DEBUG
    init(id: Int, image: UIImage?, reflectionDistance: CGFloat = 20.0) {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        self._id = State<Int>(initialValue: id)
        self._reflectionDistance = State<CGFloat>(initialValue: reflectionDistance)
        self.image = image
    }
    #endif
    
    var body: some View {
        var image: UIImage!
        if let posterImage = self.image {
            image = posterImage
        } else if let maybe = appDelegate.idsAndImages[id], let posterImage = maybe {
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
                        .frame(maxHeight: geo.size.height * 2 / 3)
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                }
                Spacer()
            }
            .onTapGesture(count: 1, perform: {
                print("selected movie \(id)")
            })
        }
    }
}

#if DEBUG
struct MoviePosterView_Previews: PreviewProvider {
    static var previews: some View {
        MoviePosterView(id: MovieInfo.Example.AQuietPlaceII.id, image: UIImage(named: "moviePosterPlaceholder"), reflectionDistance: 10)
    }
}
#endif
