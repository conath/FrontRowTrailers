//
//  CustomDarkAppearance.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 30.06.20.
//

import SwiftUI

struct CustomDarkAppearance: ViewModifier {
    @ObservedObject var settings = Settings.instance
    
    func body(content: Content) -> some View {
        AnyView(
            content
                .preferredColorScheme(settings.prefersDarkAppearance ? .some(.dark) : .none)
            #if os(macOS)
                .background(Color.black)
            #endif
        )
    }
}
