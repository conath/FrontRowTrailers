//
//  MoviePosterView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 15.10.20.
//  Ported to macOS by Christoph Parstorfer on 24.12.21.
//

import SwiftUI

struct MoviePosterView: View {
    private let filmPosterAspectRatio = CGFloat(0.7063020214)
    
    @State private var reflectionDistance: CGFloat
    @State private var onTap: (() -> ())?
    @State private var image: NSImage?
    @State private var blurReflection = true
    
    init(image: NSImage?, reflectionDistance: CGFloat = -1.0, blurReflection: Bool = true, onTapGesture: (() -> ())? = nil) {
        self._reflectionDistance = State<CGFloat>(initialValue: reflectionDistance)
        self._blurReflection = State<Bool>(initialValue: blurReflection)
        self._onTap = State<(() -> ())?>(initialValue: onTapGesture)
        self._image = State<NSImage?>(wrappedValue: image)
    }
    
    var body: some View {
        var image: NSImage!
        if let posterImage = self.image {
            image = posterImage
        } else {
            image = NSImage(named: "moviePosterPlaceholder")
        }
        var fadeImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        fadeImage = fadeImage.masking(NSImage(named: "posterMirrorImageGradientMask")!.cgImage(forProposedRect: nil, context: nil, hints: nil)!)!
        
        return GeometryReader { geo in
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: reflectionDistance) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: geo.size.height * 2 / 3)
                    Image(nsImage: NSImage(cgImage: fadeImage, size: NSSize(width: geo.size.width, height: geo.size.height)))
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
            .accessibilityHidden(true)
        }
    }
}

#if DEBUG
struct MoviePosterView_Previews: PreviewProvider {
    static var previews: some View {
        Color.black
            .overlay (
                MoviePosterView(image: NSImage(named: "moviePosterPlaceholder"))
            .padding(.top, 24)
        )
    }
}
#endif
