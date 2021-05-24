//
//  SettingsView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 30.06.20.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var settings = Settings.instance
    @ObservedObject private var dataStore = MovieInfoDataStore.shared
    
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
                Spacer().frame(height: 22)
                
                Toggle("Interaction sounds", isOn: $settings.playUISounds)
                if settings.playUISounds {
                    Text("Subtle sounds will play for some interactions.")
                        .font(.subheadline)
                } else {
                    Text("No sounds will be played for any interactions.")
                        .font(.subheadline)
                }
                Spacer().frame(height: 22)
                
                if dataStore.moviesAvailable {
                    Button("Update list of Trailers") {
                        dataStore.update()
                    }
                    .disabled(!dataStore.streamingAvailable)
                    Text(getLastUpdatedString())
                        .font(.subheadline)
                } else {
                    ProgressView("Updating …")
                }
                Spacer()
            }
            .padding([.leading, .trailing], 16)
            .navigationTitle("Settings")
        }
        .modifier(CustomDarkAppearance())
    }
    
    private func getLastUpdatedString() -> String {
        if let date = dataStore.lastUpdated {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.doesRelativeDateFormatting = true
            dateFormatter.timeStyle = .none
            let str = NSLocalizedString("Last updated: %@", comment: "Label that tells the user when the list of trailers was last updated. A date will be inserted.")
            return String(format: str, dateFormatter.string(from: date))
        } else {
            return NSLocalizedString("Trailers have never been updated.", comment: "")
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
