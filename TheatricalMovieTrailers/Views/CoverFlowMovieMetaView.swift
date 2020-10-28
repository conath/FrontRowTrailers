//
//  CoverFlowMovieMetaView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 16.10.20.
//

import SwiftUI

struct CoverFlowMovieMetaView: View {
    @State var model: MovieInfo
    @EnvironmentObject private var dataStore: MovieInfoDataStore
    @State var onPlay: (MovieInfo) -> ()
    @State var onDetailsTap: (MovieInfo) -> ()
    @State var onTopTap: (MovieInfo) -> ()
    @State private var shareSheetPresented = false
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                /// Play button
                Button(action: {
                    onPlay(model)
                }, label: {
                    HStack {
                        if dataStore.watched.contains(model.id) {
                            Image("watchedCheck")
                                .renderingMode(.template)
                                .foregroundColor(.primary)
                                .padding(.leading)
                        } else {
                            Image(systemName: "play.fill")
                                .foregroundColor(.primary)
                                .padding(.leading)
                        }
                        Text("Watch Trailer")
                            .foregroundColor(.primary)
                            .padding([.top, .bottom, .trailing])
                    }
                    .background (
                        RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    )
                })
                .disabled(!dataStore.streamingAvailable)
                .padding(.init(top: 0, leading: 16, bottom: 16, trailing: 16))
                
                Button(action: {
                    onDetailsTap(model)
                }) {
                    VStack {
                        Text("Swipe up for details")
                            .padding(.bottom, 1)
                        Image(systemName: "chevron.down")
                            .padding(.bottom, 8)
                    }
                }
                
                Spacer()
                
                Group {
                    MovieMetaRow(title: "Director", value: model.director, labelWidth: geo.size.width / 3)
                    MovieMetaRow(title: "Actors", value: model.actors.joined(separator: ", "), labelWidth: geo.size.width / 3)
                    if let genre = model.genres.first {
                        MovieMetaRow(title: "Genre", value: genre, labelWidth: geo.size.width / 3)
                    }
                    MovieMetaRow(title: "Release", value: model.releaseDateString, labelWidth: geo.size.width / 3)
                }
                
                ScrollView(.vertical) {
                    Text(model.synopsis)
                        .lineLimit(.max)
                        .font(.body)
                        .padding([.leading, .trailing])
                }
                
                /// Share button
                if let url = model.trailerURL {
                    Button {
                        shareSheetPresented = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.primary)
                                .padding(.leading)
                            Text("Share Trailer")
                                .foregroundColor(.primary)
                                .padding(.trailing)
                        }
                        .padding(.vertical)
                        .background (
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                        )
                    }
                    .disabled(!dataStore.streamingAvailable)
                    .padding()
                    .sheet(isPresented: $shareSheetPresented, content: { () -> ShareSheet in
                        let items: [Any]
                        if let image = dataStore.idsAndImages[model.id], let poster = image {
                            items = [poster as Any, model.title, url]
                        } else {
                            items = [model.title, url]
                        }
                        return ShareSheet(activityItems: items)
                    })
                }
                
                Spacer()
                
                // Back to Top button
                Button(action: {
                    onTopTap(model)
                }) {
                    VStack(spacing: 0) {
                        Image(systemName: "chevron.up")
                            .padding(.bottom, 1)
                        Text("Back to top")
                            .padding(.bottom, 8)
                    }
                }
                
                Text(model.copyright)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 4)
            }
        }
    }
}
