//
//  ExternalTrailerView.swift
//  MovieTrailers
//
//  Created by Chris on 25.06.20.
//

import SwiftUI
import AVKit

struct ExternalTrailerView: View {
    @Binding var model: MovieInfo
    @ObservedObject var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @Binding var posterImage: UIImage?
    
    let avPlayer: AVPlayer?
    
    init(model: Binding<MovieInfo>, image: Binding<UIImage?>) {
        self._model = model
        self._posterImage = image
        
        if let url = URL(string: model.wrappedValue.trailerURL) {
            let avPlayer: AVPlayer? = AVPlayer(url: url)
            self.avPlayer = avPlayer
        } else {
            avPlayer = nil
        }
    }
    
    var body: some View {
        return GeometryReader { geo in
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack {
                        // Title, subtitle, trailer duration
                        TrailerMetaView(model: $model)
                        if let image = posterImage {
                            HStack() {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.all, 5)
                            }
                            Spacer()
                        }
                    }
                    .padding(.leading)
                    // Trailer Video Player
                    VideoPlayer(player: avPlayer)
                        .onChange(of: appDelegate.isPlaying) { isPlaying in
                            if isPlaying {
                                avPlayer?.play()
                            } else {
                                avPlayer?.pause()
                            }
                        }
                        .onDisappear {
                            avPlayer?.pause()
                        }
                        .frame(minHeight: geo.size.height * 0.7, maxHeight: .infinity)
                }.frame(minWidth: geo.size.width * (2/3), minHeight: geo.size.height * 0.7, maxHeight: .infinity)
                
                // Meta details
                MovieMetaView(scrolls: false, model: $model)
            }
            .colorScheme(.dark)
            .background(Color.black)
            .statusBar(hidden: true)
        }
    }
}

struct ExternalTrailerView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalTrailerView(model: .constant(MovieInfo.Example.AQuietPlaceII), image: .constant(UIImage()))
            .previewLayout(.fixed(width: 1280, height: 720))
    }
}
