//
//  MovieDetailsView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import AVKit
import SwiftUI

struct MovieTrailerView: View {
    @State var model: TrailerModel
    @ObservedObject var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @State var isPlaying: Bool
    
    let avPlayer: AVPlayer?
    let keyValueObservation: NSKeyValueObservation?
    
    init(model: TrailerModel = .Empty, isPlaying: Bool = false, changeHandler: @escaping ((AVPlayer, NSKeyValueObservedChange<Float>) -> ())) {
        self._model = State<TrailerModel>(initialValue: model)
        self._isPlaying = State<Bool>(initialValue: isPlaying)
        if let url = URL(string: model.trailerURL) {
            let avPlayer: AVPlayer? = AVPlayer(url: url)
            self.avPlayer = avPlayer
            keyValueObservation = avPlayer?.observe(\.rate, options: [.new], changeHandler: changeHandler)
        } else {
            avPlayer = nil
            keyValueObservation = nil
        }
    }
    
    var body: some View {
        return GeometryReader { geo in
            VStack {
                TrailerMetaView(model: model)
                // Trailer Video
                VideoPlayer(player: avPlayer, videoOverlay: {
                    Spacer()
                })
                .onAppear {
                    if appDelegate.isExternalScreenConnected {
                        avPlayer?.volume = 0
                    }
                }
                .onChange(of: appDelegate.isExternalScreenConnected) { isConnected in
                    avPlayer?.volume = isConnected ? 0 : 1
                }
                .frame(width: geo.size.width, height: geo.size.width * (9 / 16), alignment: .center)
                
                Text(model.synopsis)
                    .lineLimit(10)
                    .font(.body)
                    .padding([.leading, .trailing])
                
                Divider()
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        HStack {
                            Spacer()
                            Text("Director")
                                .font(.headline)
                        }
                        .frame(width: geo.size.width * 0.22)
                        .padding(.trailing, 5)
                        Text(model.director)
                            .font(.body)
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    
                    HStack(alignment: .top) {
                        HStack {
                            Spacer()
                            Text("Actors")
                                .font(.headline)
                        }
                        .frame(width: geo.size.width * 0.22)
                        .padding(.trailing, 5)
                        Text(model.actors)
                            .font(.body)
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    HStack(alignment: .top) {
                        HStack {
                            Spacer()
                            Text("Genre")
                                .font(.headline)
                        }
                        .frame(width: geo.size.width * 0.22)
                        .padding(.trailing, 5)
                        Text(model.genres.joined(separator: ", "))
                            .font(.body)
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    HStack(alignment: .top) {
                        HStack {
                            Spacer()
                            Text("Run Time")
                                .font(.headline)
                        }
                        .frame(width: geo.size.width * 0.22)
                        .padding(.trailing, 5)
                        Text(model.runTime)
                            .font(.body)
                        Spacer()
                    }
                    .padding(.bottom, 5)
                }
                .padding(.all, 8)
                
                Spacer()
            }
            .colorScheme(.dark)
            .background(Color.black)
            .statusBar(hidden: true)
        }
    }
}

struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieTrailerView(model: TrailerModel.Example.MoneyPlane, changeHandler: { _,_  in })
    }
}
