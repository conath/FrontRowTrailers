//
//  TrailerListView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct TrailerListView: View {
    enum SortingMode: String {
        case TitleAscending = "Title (A-Z)"
        case ReleaseAscending = "Release date"
        case ReleaseDescending = "Release (reversed)"
        
        func nextMode() -> SortingMode {
            switch self {
            case .TitleAscending:
                return .ReleaseAscending
            case .ReleaseAscending:
                return .ReleaseDescending
            default:
                return .TitleAscending
            }
        }
        
        var predicate: ((MovieInfo, MovieInfo) -> Bool) {
            get {
                switch self {
                case .ReleaseAscending:
                    return {
                        if let r0 = $0.releaseDate, let r1 = $1.releaseDate {
                            return r0 < r1
                        } else {
                            return $0.title < $1.title
                        }
                    }
                case .ReleaseDescending:
                    return {
                        if let r0 = $0.releaseDate, let r1 = $1.releaseDate {
                            return r0 > r1
                        } else {
                            return $0.title < $1.title
                        }
                    }
                default:
                    return {
                        return $0.title < $1.title
                    }
                }
            }
        }
    }
    
    struct ListItem: Identifiable {
        var movieInfo: MovieInfo
        var isSelected = false
        
        var id: Int {
            return movieInfo.id
        }
    }
    
    //@ObservedObject private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @Binding var model: [MovieInfo]
    @State var sortingMode = SortingMode.ReleaseAscending
    @State private var selected = [Int:Bool]()
    @State private var settingsShown = false
    
    var body: some View {
        let viewModel = model.enumerated().map { ListItem(movieInfo: $0.1, isSelected: $0.0 == 0) }
        
        return GeometryReader { geo in
            NavigationView {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel) { model in
                            TrailerListRow(model: model)
                        }
                    }
                    .navigationTitle("Theatrical Trailers")
                    .navigationBarItems(leading:
                                            Button(action: {
                                                let nextMode = sortingMode.nextMode()
                                                DispatchQueue.global(qos: .userInteractive).async {
                                                    let sortedModel = model.sorted(by: nextMode.predicate)
                                                    DispatchQueue.main.async {
                                                        sortingMode = nextMode
                                                        model = sortedModel
                                                    }
                                                }
                                            }, label: {
                                                HStack {
                                                    Image(systemName: "arrow.up.arrow.down")
                                                    Text(sortingMode.rawValue)
                                                }
                                            }), trailing:
                                                Button(action: {
                                                    settingsShown = true
                                                }, label: {
                                                    Image(systemName: "gearshape")
                                                        .clipShape(Rectangle())
                                                        .accessibility(label: Text("Settings"))
                                                })
                    )
                }
                .navigationViewStyle(DoubleColumnNavigationViewStyle())
                .padding(.leading)
            }
            .sheet(isPresented: $settingsShown, content: {
                SettingsView(isPresented: $settingsShown)
            })
        }
    }
}

#if DEBUG
struct TrailerListView_Previews: PreviewProvider {
    static var previews: some View {
        TrailerListView(model: .constant([MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII]))
            .colorScheme(.dark)
            .background(Color.black)
    }
}
#endif
