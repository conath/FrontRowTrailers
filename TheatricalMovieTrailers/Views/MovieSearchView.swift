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
    @ObservedObject private var dataStore = MovieInfoDataStore.shared
    
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
        
        return GeometryReader { frame in
            VStack {
                // MARK: Search Field
                HStack(alignment: .center) {
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                        .padding(.vertical)
                        .accessibility(hidden: true)
                    TextField(getSearchPrompt(), text: $searchTerm)
                        .font(.headline)
                        .padding(.horizontal)
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibility(label: Text("Close Search"))
                }
                .padding(.horizontal)
                
                // MARK: Search Scope
                if frame.size.width > 320 {
                    /// add some spacing around the picker so it doesn't stick to the edge of the screen
                    HStack {
                        Spacer()
                        Picker("Search scope", selection: $searchScope) {
                            // title, genre, actor, synopsis, studio
                            Text("Title").tag(SearchScope.title)
                            Text("Genre").tag(SearchScope.genre)
                            Text("Actors").tag(SearchScope.actors)
                            Text("Synopsis").tag(SearchScope.synopsis)
                            Text("Studio").tag(SearchScope.studio)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Spacer()
                    }
                } else {
                    /// the word *Synopsis* is truncated if we include the spacers on narrow devices, so no spacers here.
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
                        DispatchQueue.main.async {
                            onSelected(info)
                        }
                        dismiss()
                    } label: {
                        HStack {
                            getImage(info.id)
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
    }
    
    private func dismiss() {
        /// If the software keyboard is showing and we dismiss, the `CoverFlowScrollView`'s content insets
        ///  will be updated with the keyboard frame, which results in a jarring and extraneous animation.
        /// Detect if the software keyboard is shown by checking if there is a `UIResponder` that is a `UITextField`
        /// SwiftUI has UIKit underneath – "always has been" (insert two astronauts meme)
        if let textField = UIResponder.currentFirstResponder as? UITextField {
            textField.resignFirstResponder()
            /// Software keyboard takes about 0.2 seconds to hide
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            /// No keyboard shown means no delay
            withAnimation {
                presentationMode.wrappedValue.dismiss()
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
    
    private func getImage(_ id: Int) -> Image {
        let image: Image
        if let poster = dataStore.idsAndImages[id], let posterImage = poster {
            image = posterImage
        } else {
            image = .moviePosterPlaceholder
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
