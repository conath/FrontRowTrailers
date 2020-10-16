//
//  MovieMetaView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct ExternalMovieMetaView: View {
    @Binding var model: MovieInfo!
    
    var body: some View {
        GeometryReader { geo in
            let metaWidth = geo.size.width * 0.23
            let metaHeadlineFont = Font.system(size: 25, weight: .medium, design: .default)
            let metaBodyFont = Font.system(size: 25)
            
            VStack(alignment: .center) {
                HStack(alignment: .top) {
                    VStack {
                        ExtMovieMetaRow(title: "Director", value: model.director, width: metaWidth / 3, font1: metaHeadlineFont, font2: metaBodyFont)
                        
                        ExtMovieMetaRow(title: "Actors", value: model.actors.joined(separator: ", "), width: metaWidth / 3, font1: metaHeadlineFont, font2: metaBodyFont)
                        
                        ExtMovieMetaRow(title: "Genre", value: model.genres.joined(separator: "ExtMovieMetaRow "), width: metaWidth / 3, font1: metaHeadlineFont, font2: metaBodyFont)
                    
                        ExtMovieMetaRow(title: "Release", value: model.releaseDateString, width: metaWidth / 3, font1: metaHeadlineFont, font2: metaBodyFont)
                    }
                    .frame(width: metaWidth)
                    
                    //Divider()
                    
                    Text(model.synopsis)
                        .lineLimit(6)
                        .font(.system(size: 25))
                        .padding([.leading, .trailing])
                    Spacer()

                }
                
                Text(model.copyright)
                    .font(.system(size: 15))
            }
            .padding(.all, 8)
            
            Spacer()
        }
    }
}

#if DEBUG
struct ExternalMovieMetaView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExternalMovieMetaView(model: .constant(MovieInfo.Example.AQuietPlaceII))
                .colorScheme(.dark)
                .background(Color.black)
                .previewLayout(.fixed(width: 1280, height: 720/3))
        }
    }
}
#endif

fileprivate struct ExtMovieMetaRow: View {
    let title: String
    let value: String
    let width: CGFloat
    let font1: Font
    let font2: Font
    
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                Spacer()
                Text(title)
                    .font(font1)
            }
            .frame(width: width)
            .padding(.trailing, 5)
            Text(value)
                .font(font2)
            Spacer()
        }
        .padding(.bottom, 5)
    }
}
