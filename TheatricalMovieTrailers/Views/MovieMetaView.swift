//
//  MovieMetaView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

fileprivate let labelWidth: CGFloat = 0.25

struct MovieMetaView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var model: MovieInfo!
    
    var body: some View {
        GeometryReader { geo in
            let titleWidth = geo.size.width * labelWidth
            let metaWidth = titleWidth / 3
            
            VStack(alignment: .leading) {
                if horizontalSizeClass == .compact {
                    ScrollView(.vertical, showsIndicators: true, content: {
                        Text(model.synopsis)
                            .lineLimit(.max)
                            .font(.body)
                            .padding([.leading, .trailing])
                    })
                    .frame(minHeight: 100, maxHeight: 150)
                    
                    Divider()
                    MovieMetaRow(title: "Director", value: model.director, labelWidth: titleWidth)
                    
                    MovieMetaRow(title: "Actors", value: model.actors.joined(separator: ", "), labelWidth: titleWidth)
                    
                    MovieMetaRow(title: "Genre", value: model.genres.joined(separator: ", "), labelWidth: titleWidth)
                    
                    MovieMetaRow(title: "Release", value: model.releaseDateString, labelWidth: titleWidth)
                } else {
                    HStack(alignment: .top) {
                        VStack {
                            MovieMetaRow(title: "Director", value: model.director, labelWidth: metaWidth)
                            
                            MovieMetaRow(title: "Actors", value: model.actors.joined(separator: ", "), labelWidth: metaWidth)
                            
                            MovieMetaRow(title: "Genre", value: model.genres.joined(separator: ", "), labelWidth: metaWidth)
                        
                            MovieMetaRow(title: "Release", value: model.releaseDateString, labelWidth: metaWidth)
                        }
                        .frame(width: geo.size.width / 3)
                        
                        ScrollView(.vertical, showsIndicators: true, content: {
                            Text(model.synopsis)
                                .lineLimit(.max)
                                .font(.body)
                                .padding([.leading, .trailing])
                        })
                        .frame(minHeight: 100, maxHeight: 150)
                    }
                }
                
                HStack(alignment: .top) {
                    Spacer()
                    Text(model.copyright)
                        .font(.caption)
                    Spacer()
                }
            }
            .padding(.all, 8)
        }
    }
}
#if DEBUG
struct MovieMetaView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MovieMetaView(model: .constant(MovieInfo.Example.AQuietPlaceII))
                .colorScheme(.dark)
                .background(Color.black)
                .previewLayout(.sizeThatFits)
            MovieMetaView(model: .constant(MovieInfo.Example.AQuietPlaceII))
                .colorScheme(.dark)
                .background(Color.black)
                .previewLayout(.fixed(width: 1024, height: 350))
        }
    }
}
#endif

struct MovieMetaRow: View {
    let title: String
    let value: String
    let labelWidth: CGFloat
    
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                Spacer()
                Text(title)
                    .font(.headline)
            }
            .frame(width: labelWidth)
            .padding(.trailing, 5)
            Text(value)
                .font(.body)
            Spacer()
        }
        .padding(.bottom, 5)
    }
}
