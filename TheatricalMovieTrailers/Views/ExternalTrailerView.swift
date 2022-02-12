//
//  ExternalTrailerView.swift
//  MovieTrailers
//
//  Created by Chris on 25.06.20.
//

import SwiftUI
import AVKit

struct ExternalTrailerView: View {
    @State var model: MovieInfo
    @ObservedObject private var dataStore = MovieInfoDataStore.shared
    @Binding var posterImage: Image?
    
    @State private var avPlayer: AVPlayer?
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack {
                        // Title, subtitle, trailer duration
                        TrailerMetaView(model: $model, largeTitle: true)
                        if let image = posterImage {
                            HStack() {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.all, 5)
                            }
                            Spacer()
                        }
                    }
                    .padding(.leading)
                    .frame(width: geo.size.width * 0.23)
                    // Trailer Video Player
                    VideoPlayer(player: avPlayer)
                        .onChange(of: dataStore.isPlaying) { isPlaying in
                            if isPlaying {
                                avPlayer?.play()
                            } else {
                                avPlayer?.pause()
                            }
                        }
                        .frame(minHeight: geo.size.height * 0.7, maxHeight: .infinity)
                }.frame(minWidth: geo.size.width * (2/3), minHeight: geo.size.height * 0.7, maxHeight: .infinity)
                
                // Meta details
                ExternalMovieMetaView(model: $model)
            }
            .colorScheme(.dark)
            .background(Color.black)
            .statusBar(hidden: true)
            .onAppear(perform: {
                if let url = model.trailerURL {
                    let avPlayer: AVPlayer? = AVPlayer(url: url)
                    self.avPlayer = avPlayer
                }
            })
            .onChange(of: model, perform: { model in
                self.avPlayer?.pause()
                if let url = model.trailerURL {
                    let avPlayer: AVPlayer? = AVPlayer(url: url)
                    self.avPlayer = avPlayer
                    self.avPlayer?.play()
                }
            })
            .onChange(of: dataStore.isPlaying) { isPlaying in
                if isPlaying {
                    self.avPlayer?.play()
                } else {
                    self.avPlayer?.pause()
                }
            }
        }
    }
}

#if DEBUG
struct ExternalTrailerView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalTrailerView(model: MovieInfo.Example.AQuietPlaceII, posterImage: .constant(.moviePosterPlaceholder))
            .previewLayout(.fixed(width: 1280, height: 720))
    }
}
#endif
