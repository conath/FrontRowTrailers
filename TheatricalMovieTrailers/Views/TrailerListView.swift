//
//  TrailerListView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct TrailerListView: View {
    struct ListItem: Identifiable {
        var movieInfo: MovieInfo
        var isSelected = false
        
        var id: Int {
            return movieInfo.id
        }
    }
    enum Sheet {
        case settings, search
    }
    
    @Binding var model: [MovieInfo]
    @Binding var sortingMode: SortingMode
    init(model: Binding<[MovieInfo]>, sortingMode: Binding<SortingMode>) {
        _model = model
        _sortingMode = sortingMode
        let viewModel = model.wrappedValue.enumerated().map { ListItem(movieInfo: $0.1, isSelected: $0.0 == 0) }
        _viewModel = State<[ListItem]>(initialValue: viewModel)
    }
    
    @State private var viewModel: [ListItem]
    @State private var settingsPresented = false
    @State private var searchPresented = false
    
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                ScrollView(.vertical, showsIndicators: true) {
                    ScrollViewReader { reader in
                        LazyVStack(alignment: .leading) {
                            ForEach(viewModel) { listItem in
                                TrailerListRow(model: listItem)
                                    .id(listItem.id)
                            }
                        }
                        .navigationTitle("Theatrical Trailers")
                        .navigationBarItems(leading:
                                                HStack {
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
                                                    })
                                                    Button(action: {
                                                        searchPresented = true
                                                    }, label: {
                                                        HStack {
                                                            Image(systemName: "magnifyingglass")
                                                            Text("Search")
                                                        }
                                                    })
                                                    .sheet(isPresented: $searchPresented, content: {
                                                        MovieSearchView(model: model, onSelected: { info in
                                                            withAnimation {
                                                                reader.scrollTo(info.id)
                                                                let i = viewModel.firstIndex(where: {$0.id == info.id})!
                                                                viewModel[i].isSelected = true
                                                            }
                                                        })
                                                        .modifier(CustomDarkAppearance())
                                                    })
                                                }, trailing:
                                                    Button(action: {
                                                        settingsPresented = true
                                                    }, label: {
                                                        Image(systemName: "gearshape")
                                                            .clipShape(Rectangle())
                                                            .accessibility(label: Text("Settings"))
                                                    })
                                                    .sheet(isPresented: $settingsPresented, content: {
                                                        SettingsView()
                                                    })
                        )
                    }
                }
                .navigationViewStyle(DoubleColumnNavigationViewStyle())
                .padding(.leading)
            }
        }
    }
}

#if DEBUG
struct TrailerListView_Previews: PreviewProvider {
    static var previews: some View {
        TrailerListView(model: .constant([MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII]), sortingMode: .constant(.ReleaseAscending))
            .colorScheme(.dark)
            .background(Color.black)
    }
}
#endif
