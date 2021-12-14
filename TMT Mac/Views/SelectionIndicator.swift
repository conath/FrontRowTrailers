//
//  SelectionIndicator.swift
//  Theatrical Trailers
//
//  Created by Christoph Parstorfer on 13.12.21.
//

import SwiftUI

struct SelectionIndicator: View {
    var frame: GeometryProxy
    
    var body: some View {
        /// the text "Layout placeholder" makes it so the text view is laid out with the proper font size
        Text("Layout placeholder")
            .lineLimit(1)
            .truncationMode(.tail)
            .foregroundColor(.clear)
            .accessibilityHidden(true)
            .font(Font.title.bold())
            .frame(width: 0.4*frame.size.width, height: ContentView.selectionRectHeight)
            .padding(15)
            .background(
                ZStack(alignment: .leading) {
                    /// blue shine
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .border(Color.blue, width: 10)
                        .blur(radius: 4)
                        .padding(4)
                        .mask {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .border(Color.white, width: 7)
                        }
                    /// black border
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .border(Color.black, width: 2)
                        .padding(6)
                    /// gloss shine
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.clear)
                        .overlay(
                            LinearGradient(colors: [.init(white: 1, opacity: 0.5), .init(white: 1, opacity: 0.2), .clear, .clear, .clear, .clear], startPoint: .top, endPoint: .bottom))
                        .padding(8)
                }
                    .frame(height: ContentView.selectionRectHeight)
            )
    }
}
