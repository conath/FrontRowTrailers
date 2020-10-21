//
//  CustomDarkAppearance.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 30.06.20.
//

import SwiftUI

struct CustomDarkAppearance: ViewModifier {
    @ObservedObject var settings = Settings.instance()
    
    func body(content: Content) -> some View {
        if settings.prefersDarkAppearance {
            return AnyView(
                content
                    .preferredColorScheme(.dark)
            )
        } else {
            return AnyView(
                content
                    .preferredColorScheme(
                        // using .none does cause the ContentView to update properly
                        //  if prefersDarkAppearance was switched from true to false
                        UITraitCollection().userInterfaceStyle == .dark ? .dark : .light
                    )
            )
        }
    }
}
