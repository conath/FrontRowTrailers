//
//  SettingsView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 30.06.20.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = Settings.instance()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Toggle("Always use dark mode", isOn: $settings.prefersDarkAppearance)
                if settings.prefersDarkAppearance {
                    Text("The app will always be in dark mode.")
                        .font(.subheadline)
                } else {
                    Text("The app will match your system appearance.")
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding([.leading, .trailing], 16)
            .navigationTitle("Settings")
        }
        .modifier(CustomDarkAppearance())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
