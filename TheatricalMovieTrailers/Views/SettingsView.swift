//
//  SettingsView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 30.06.20.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = Settings.instance()
    @Binding var isPresented: Bool
    
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
                Button(action: {
                    isPresented = false
                    DispatchQueue.main.async {
                        Settings.instance().isCoverFlow = true
                    }
                }, label: {
                        HStack {
                            Image(systemName: "arrow.turn.up.forward.iphone.fill")
                                .foregroundColor(.primary)
                                .padding(.leading)
                            Text("Switch to Cover Flow")
                                .foregroundColor(.primary)
                                .padding([.top, .bottom, .trailing])
                        }
                        .background (
                            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        )
                })
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
        SettingsView(isPresented: .constant(true))
    }
}
