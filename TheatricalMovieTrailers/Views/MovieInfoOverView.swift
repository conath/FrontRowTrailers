//
//  SizeClassSwitchView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 16.10.20.
//

import SwiftUI

struct MovieInfoOverView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var model: [MovieInfo]
    
    var body: some View {
        if verticalSizeClass == .compact || horizontalSizeClass == .compact {
            CoverFlowListView(model: $model)
        } else {
            // iPad gets a nice sidebar with posters
            TrailerListView(model: $model)
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
