//
//  MacFont.swift
//  Theatrical Trailers
//
//  Created by Christoph Parstorfer on 12.02.22.
//

import SwiftUI

extension Font {
    static var titleGrande: Font {
        get {
            Font.custom("Lucida Grande", fixedSize: NSFont.preferredFont(forTextStyle: .title1).pointSize)
                .bold()
        }
    }
    static var boldGrande: Font {
        get {
            Font.custom("Lucida Grande", fixedSize: NSFont.preferredFont(forTextStyle: .body).pointSize * 1.5)
                .bold()
        }
    }
    static var bodyGrande: Font {
        get {
            Font.custom("Lucida Grande", fixedSize: NSFont.preferredFont(forTextStyle: .body).pointSize * 1.5)
        }
    }
    static var smallGrande: Font {
        get {
            Font.custom("Lucida Grande", fixedSize: NSFont.preferredFont(forTextStyle: .caption1).pointSize)
        }
    }
}
