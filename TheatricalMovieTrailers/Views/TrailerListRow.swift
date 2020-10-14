//
//  TrailerListRow.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.10.20.
//

import SwiftUI

struct TrailerListRow: View {
    
    @ObservedObject private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var model: MovieInfo
    
    var body: some View {
        HStack(alignment: .center) {
            if let maybe = appDelegate.idsAndImages[model.id], let image = maybe {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
            }
            VStack(alignment: .leading) {
                Text(model.title)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .padding(.top)
                Text(model.releaseDateString)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(model.studio)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .padding(.bottom)
                
                Divider()
            }
            .padding(.top)
        }
    }
}
