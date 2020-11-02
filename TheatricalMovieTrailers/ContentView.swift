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
    
    var body: some View {
        CoverFlowScrollView(model: $dataStore.model, sortingMode: $sortingMode)
        .overlay(
            Group {
                if dataStore.model.count == 0 || dataStore.idsAndImages.count != dataStore.model.count {
                    ZStack {
                        ProgressView("Loading Trailers…", value: Float(dataStore.idsAndImages.count), total: Float(max(dataStore.model.count, 1)))
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
    }
}
