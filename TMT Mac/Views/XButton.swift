//
//  XButton.swift
//  Front Row Trailers
//
//  Created by Christoph Parstorfer on 13.02.22.
//

import SwiftUI

struct XButton: View {
    var action: () -> ()
    
    @State private var increaseOpacity = true
    
    var body: some View {
        Button() {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.largeTitle)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: ContentView.listItemHeight, height: ContentView.listItemHeight)
        .clipShape(Circle())
        .opacity(increaseOpacity ? 0.8 : 0.3)
        .padding()
        .onAppear {
            withAnimation(.linear(duration: 3)) {
                increaseOpacity = false
            }
        }
        .onHover { hovering in
            increaseOpacity = hovering
        }
    }
}
