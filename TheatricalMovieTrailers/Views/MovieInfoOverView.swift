//
//  SizeClassSwitchView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 16.10.20.
//

import SwiftUI

struct MovieInfoOverView: View {
    enum ViewMode {
        case list, coverFlow
    }
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject private var settings = Settings.instance
    @State var model: [MovieInfo]
    @State private var sortingMode = SortingMode.ReleaseAscending
    
    var body: some View {
        Group {
            if verticalSizeClass == .compact || horizontalSizeClass == .compact {
                if settings.isCoverFlow {
                    CoverFlowScrollView(model: $model, sortingMode: $sortingMode)
                } else {
                    CompactTrailerListView(model: $model, sortingMode: $sortingMode)
                }
            } else {
                // iPad gets a nice sidebar with posters
                TrailerListView(model: $model, sortingMode: $sortingMode)
            }
        }
        .onChange(of: sortingMode) { sortingMode in
            model.sort(by: sortingMode.predicate)
        }
    }
}

#if DEBUG
struct SizeClassSwitchView_Previews: PreviewProvider {
    static var previews: some View {
        MovieInfoOverView(model: [MovieInfo.Example.AQuietPlaceII])
    }
}
#endif
