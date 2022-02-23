//
//  ContentView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var settings = Settings.instance
    @EnvironmentObject var dataStore: MovieInfoDataStore
    @State var sortingMode = SortingMode.ReleaseAscending
    @State private var loading = false
    
    var body: some View {
        CoverFlowScrollView(model: $dataStore.model, sortingMode: $sortingMode)
            .overlay(
                Group {
                    if loading {
                        ZStack {
                            ProgressView("Loading Trailers…")
                                .frame(width: 200, height: 44)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.init(UIColor.systemBackground))
                        .edgesIgnoringSafeArea(.all)
                    }
                }
            )
            .alert(item: $dataStore.error, content: { error  -> Alert in
                error.makeAlert()
            })
            .transition(.opacity)
            .modifier(CustomDarkAppearance())
            .statusBar(hidden: true)
            .onChange(of: sortingMode) { sortingMode in
                dataStore.model.sort(by: sortingMode.predicate)
            }
            .onAppear {
                if !dataStore.moviesAvailable {
                    DispatchQueue.main.asyncAfter(0.5) {
                        if !dataStore.moviesAvailable {
                            withAnimation {
                                loading = true
                            }
                        }
                    }
                }
            }
            .onChange(of: dataStore.moviesAvailable, perform: { moviesAvailable in
                withAnimation {
                    loading = !moviesAvailable
                }
            })
    }
}
