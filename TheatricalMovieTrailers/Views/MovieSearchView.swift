//
//  MovieSearchView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 21.10.20.
//

import SwiftUI

extension String {
    func containsIgnoreCase(_ otherString: String) -> Bool {
        return lowercased(with: .current).contains(otherString.lowercased(with: .current))
    }
}

struct MovieSearchView: View {
    @State var model: [MovieInfo]
    @State var onSelected: (MovieInfo) -> ()
    @State var searchTerm = ""
    
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var body: some View {
        let results: [MovieInfo]
        if searchTerm.count > 0 {
            results = model.filter { $0.title.containsIgnoreCase(searchTerm) }.sorted(by: SortingMode.TitleAscending.predicate)
        } else {
            results = model.sorted(by: SortingMode.TitleAscending.predicate)
        }
        return VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search for a movie", text: $searchTerm)
                    .padding(.leading)
                Button {
                    withAnimation {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                }
                .accessibility(label: Text("Close Search"))
            }
            .padding()
            List(results) { info in
                Button {
                    withAnimation {
                        presentationMode.wrappedValue.dismiss()
                    }
                    onSelected(info)
                } label: {                
                    HStack {
                        Image(uiImage: getImage(info.id))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 88, height: 62)
                        VStack(alignment: .leading) {
                            Text(info.title)
                            Text(info.studio)
                        }
                    }
                }
            }
        }
    }
    
    private func getImage(_ id: Int) -> UIImage {
        let image: UIImage
        if let poster = appDelegate.idsAndImages[id], let posterImage = poster {
            image = posterImage
        } else {
            image = UIImage(named: "moviePosterPlaceholder")!
        }
        return image
    }
}

#if DEBUG
struct MovieSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MovieSearchView(model: [MovieInfo.Example.AQuietPlaceII], onSelected: { _ in })
    }
}
#endif
