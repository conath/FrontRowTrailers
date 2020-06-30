//
//  TrailerListView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct TrailerListView: View {
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @State var model: [MovieInfo]
    @State var settingsShown = false
    
    var body: some View {
        GeometryReader { geo in
            NavigationView() {
                VStack(alignment: .leading) {
                    List(model) { model in
                        MovieTrailerView(model: .constant(model))
                            .frame(height: geo.size.height)
                    }
                }
                .navigationTitle("Theatrical Trailers")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(trailing: Button(action: {
                    settingsShown = true
                }, label: {
                    Image(systemName: "gearshape")
                        .accessibility(label: Text("Settings"))
                }))
            }.sheet(isPresented: $settingsShown, onDismiss: nil) {
                SettingsView()
            }
        }
    }
}

struct TrailerListView_Previews: PreviewProvider {
    static var previews: some View {
        TrailerListView(model: [MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII])
            .colorScheme(.dark)
            .background(Color.black)
    }
}
