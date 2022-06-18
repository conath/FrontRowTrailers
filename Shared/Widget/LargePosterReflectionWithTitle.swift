//
//  MoviePosterWIthMetadata.swift
//  TrailersWidgetExtension
//
//  Created by Christoph Parstorfer on 30.10.20.
//

import SwiftUI
import WidgetKit

struct LargePosterReflectionWithTitle: View {
    private let filmPosterAspectRatio = CGFloat(0.7063020214)
    
    @State var info: MovieInfo
    @State var image: Image
    @State var showMeta = false
    
    var body: some View {
        GeometryReader { frame in
            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                HStack(alignment: .top, spacing: -frame.size.width * 0.5) {
                    MoviePosterView(image: .constant(image))
                }
                .frame(height: frame.size.height * (showMeta ? 1.7 : 1.875))
                .offset(y: frame.size.height / 32)
                
                if showMeta {
                    VStack {
                        Spacer().frame(height: frame.size.height * 0.7)
                        
                        VStack {
                            Spacer()
                            Text(info.title)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: frame.size.width)
                            
                            Text(info.studio)
                                .font(.caption)
                                .frame(maxWidth: frame.size.width)
                        }
                        .frame(height: frame.size.height * 0.3 - 16)
                        .padding(frame.size.height / 64)
                    }
                }
            }
        }
        .foregroundColor(.white)
        .background(Color.black)
    }
}

#if DEBUG
struct LargePosterReflectionWithTitle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LargePosterReflectionWithTitle(info: MovieInfo.Example.AQuietPlaceII, image: .moviePosterPlaceholder)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            
            LargePosterReflectionWithTitle(info: MovieInfo.Example.AQuietPlaceII, image: .moviePosterPlaceholder, showMeta: true)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
#endif
