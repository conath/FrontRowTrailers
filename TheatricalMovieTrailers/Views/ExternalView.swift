//
//  ExternalView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct ExternalView: View {
    @ObservedObject var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var body: some View {
        GeometryReader { geo in
            if appDelegate.selectedTrailerModel != nil {
                ExternalTrailerView(model: $appDelegate.selectedTrailerModel, posterImage: $appDelegate.posterImage)
            } else {
                Text("No trailer selected")
                    .font(.largeTitle)
                    .bold()
                    .padding()
            }
        }
        .background(Color.black)
        .colorScheme(.dark)
    }
}
