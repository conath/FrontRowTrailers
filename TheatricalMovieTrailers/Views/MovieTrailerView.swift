//
//  MovieDetailsView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import AVKit
import SwiftUI

struct MovieTrailerView: View {
    @Binding var model: MovieInfo
    @ObservedObject var appDelegate: AppDelegate
    /// Used for local playing state: is the trailer playing in this view (not externally)
    @State private var isTrailerShown = false
    
    init(model: Binding<MovieInfo>) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self._model = model
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                TrailerMetaView(model: $model, largeTitle: false)
                    .padding([.leading, .trailing])
                
                VStack(alignment: .center) {
                    HStack {
                        // poster image
                        if let maybe = appDelegate.idsAndImages[model.id], let image = maybe {
                            Spacer()
                            FramedImage(uiImage: image)
                                //.resizable()
                                .aspectRatio(0.7063020214, contentMode: .fit)
                        }
                        Spacer()
                        // Play/Pause button
                        Button(action: {
                            appDelegate.isPlaying.toggle()
                            if appDelegate.isPlaying {
                                appDelegate.selectedTrailerModel = model
                            }
                        }, label: {
                            Image(systemName: appDelegate.isPlaying ? "pause" : "play.fill")
                                .frame(width: 60, height: 60)
                        })
                        .background(Color(UIColor.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        
                        Spacer()
                    }
                    .frame(width: geo.size.width, height: geo.size.width * (9 / 16), alignment: .center)
                    .overlay(
                        Group {
                            // Trailer Video if no external screen connected
                            if appDelegate.isPlaying, !appDelegate.isExternalScreenConnected, let url = model.trailerURL {
                                InlineTrailerPlayerView(url: url)
                                .frame(width: geo.size.width, height: geo.size.width * (9 / 16), alignment: .center)
                            }
                        }
                    )
                }
                
                MovieMetaView(model: $model)
                    .padding(.bottom, 100)
            }
        }
    }
}

#if DEBUG
struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MovieTrailerView(model: .constant(MovieInfo.Example.AQuietPlaceII))
                .colorScheme(.dark)
                .background(Color.black)
                .previewLayout(.sizeThatFits)
            MovieTrailerView(model: .constant(MovieInfo.Example.AQuietPlaceII))
                .colorScheme(.dark)
                .background(Color.black)
                .previewLayout(.fixed(width: 1024, height: 1024))
        }
    }
}
#endif
