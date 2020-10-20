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
    
    @Binding var model: [MovieInfo]
    @Binding var sortingMode: SortingMode
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
