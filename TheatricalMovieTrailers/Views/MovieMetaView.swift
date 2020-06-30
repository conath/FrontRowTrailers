//
//  MovieMetaView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

fileprivate let labelWidth: CGFloat = 0.25

struct MovieMetaView: View {
    let scrolls: Bool
    
    @Binding var model: MovieInfo
    
    var body: some View {
        GeometryReader { geo in
            let titleWidth = geo.size.width * labelWidth
            
            VStack(alignment: .leading) {
                if scrolls {
                    ScrollView(.vertical, showsIndicators: true, content: {
                        Text(model.synopsis)
                            .lineLimit(.max)
                            .font(.body)
                            .padding([.leading, .trailing])
                    })
                    .frame(minHeight: titleWidth, maxHeight: titleWidth * 1.5)
                } else {
                    Text(model.synopsis)
                        .lineLimit(4)
                        .font(.body)
                        .padding([.leading, .trailing])
                }
                
                Divider()
                
                MovieMetaRow(title: "Director", value: model.director, width: titleWidth)
                
                MovieMetaRow(title: "Actors", value: model.actors.joined(separator: ", "), width: titleWidth)
                
                MovieMetaRow(title: "Genre", value: model.genres.joined(separator: ", "), width: titleWidth)
                
                MovieMetaRow(title: "Release", value: model.releaseDateString, width: titleWidth)
                
                HStack(alignment: .top) {
                    Spacer()
                    Text(model.copyright)
                        .font(.caption)
                    Spacer()
                }
            }
            .padding(.all, 8)
            
            Spacer()
        }
    }
}

struct MovieMetaView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MovieMetaView(scrolls: true, model: .constant(MovieInfo.Example.AQuietPlaceII))
                .colorScheme(.dark)
                .background(Color.black)
                .previewLayout(.sizeThatFits)
            MovieMetaView(scrolls: false, model: .constant(MovieInfo.Example.AQuietPlaceII))
                .colorScheme(.dark)
                .background(Color.black)
                .previewLayout(.fixed(width: 1280, height: 720/3))
        }
    }
}

fileprivate struct MovieMetaRow: View {
    let title: String
    let value: String
    let width: CGFloat
    
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                Spacer()
                Text(title)
                    .font(.headline)
            }
            .frame(width: width)
            .padding(.trailing, 5)
            Text(value)
                .font(.body)
            Spacer()
        }
        .padding(.bottom, 5)
    }
}
