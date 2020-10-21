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
extension Array where Element == String {
    func containsIgnoreCase(_ otherString: String) -> Bool {
        return compactMap { $0.containsIgnoreCase(otherString) }.filter {$0}.count > 0
    }
}

struct MovieSearchView: View {
    enum SearchScope: String, CaseIterable, Identifiable {
        case title, genre, actors, synopsis, studio
        
        var id: String { self.rawValue }
    }
    
    @State var model: [MovieInfo]
    @State var onSelected: (MovieInfo) -> ()
    @State var searchTerm = ""
    @State var searchScope = SearchScope.title
    
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var body: some View {
        // MARK: Determine search results
        var results = model
        // have search term? then filter the results
        if searchTerm.count > 0 {
            switch searchScope {
            case .title:
                results = results.filter { $0.title.containsIgnoreCase(searchTerm) }
            case .genre:
                results = results.filter { $0.genres.containsIgnoreCase(searchTerm) }
            case .actors:
                results = results.filter { $0.actors.containsIgnoreCase(searchTerm) }
            case .synopsis:
                results = results.filter { $0.synopsis.containsIgnoreCase(searchTerm) }
            case .studio:
                results = results.filter { $0.studio.containsIgnoreCase(searchTerm) }
            }
        }
        // sort alphabetically
        results.sort(by: SortingMode.TitleAscending.predicate)
        
        return VStack {
            // MARK: Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                TextField(getSearchPrompt(), text: $searchTerm)
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
            
            // MARK: Search Scope
            ScrollView(.horizontal) {
                Picker("Search scope", selection: $searchScope) {
                    // title, genre, actor, synopsis, studio
                    Text("Title").tag(SearchScope.title)
                    Text("Genre").tag(SearchScope.genre)
                    Text("Actors").tag(SearchScope.actors)
                    Text("Synopsis").tag(SearchScope.synopsis)
                    Text("Studio").tag(SearchScope.studio)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // MARK: Search Results
            List(results) { info in
                Button {
                    withAnimation {
                        presentationMode.wrappedValue.dismiss()
                    }
                    DispatchQueue.main.async {
                        onSelected(info)
                    }
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
    
    private func getSearchPrompt() -> String {
        switch searchScope {
        case .title:
            return "Search by movie title"
        case .genre:
            return "Search by genre"
        case .actors:
            return "Search by actors"
        case .synopsis:
            return "Search in synopsis"
        case .studio:
            return "Search by studio"
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
