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
                    .background(Color.black)
                    .colorScheme(.dark)
            )
        } else {
            return AnyView(content)
        }
    }
}
