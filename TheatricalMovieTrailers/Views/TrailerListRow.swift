//
//  TrailerListRow.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.10.20.
//

import SwiftUI

struct TrailerListRow: View {
    typealias ListItem = TrailerListView.ListItem
    
    @ObservedObject private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @State var model: ListItem
    
    init(model: ListItem) {
        self._model = State<ListItem>(initialValue: model)
    }
    
    var body: some View {
        NavigationLink(destination: MovieTrailerView(model: $model.movieInfo)
                        .navigationBarHidden(true)
                        .edgesIgnoringSafeArea(.top),
                       isActive: $model.isSelected) {
            HStack(alignment: .center) {
                if let maybe = appDelegate.idsAndImages[model.id], let image = maybe {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                }
                VStack(alignment: .leading) {
                    Text(model.movieInfo.title)
                        .font(.title3)
                        .foregroundColor(.primary)
                        .padding(.top)
                    if model.movieInfo.releaseDate == nil {
                        Text("Release date unknown")
                            .font(.headline)
                            .italic()
                            .foregroundColor(.primary)
                    } else {
                        Text(model.movieInfo.releaseDateString)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    Text(model.movieInfo.studio)
                        .font(.callout)
                        .foregroundColor(.primary)
                        .padding(.bottom)
                    
                    Divider()
                }
                .padding(.top)
            }
        }
    }
}
