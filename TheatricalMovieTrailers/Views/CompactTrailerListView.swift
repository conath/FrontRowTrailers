//
//  TrailerListView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct CompactTrailerListView: View {
    @Binding var model: [MovieInfo]
    @Binding var sortingMode: SortingMode
    @State private var settingsPresented = false
    @State private var searchPresented = false
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: true) {
                ScrollViewReader { reader in
                    LazyVStack(alignment: .leading) {
                        Text("Theatrical Trailers")
                            .font(.largeTitle)
                            .bold()
                            .padding()
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
                                    }
                                })
                                .modifier(CustomDarkAppearance())
                            })
                                            
                            Spacer()
                            
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
                        }
                        .padding(.horizontal)
                        
                        ForEach(model) { model in
                            MovieTrailerView(model: .constant(model))
                                .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.8)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(geo.size.width * 0.07)
                                .padding([.leading, .bottom], geo.size.width * 0.025)
                                .id(model.id)
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct CompactTrailerListView_Previews: PreviewProvider {
    static var previews: some View {
        CompactTrailerListView(model: .constant([MovieInfo.Example.AQuietPlaceII]), sortingMode: .constant(.ReleaseAscending))
            .colorScheme(.dark)
            .background(Color.black)
    }
}
#endif
