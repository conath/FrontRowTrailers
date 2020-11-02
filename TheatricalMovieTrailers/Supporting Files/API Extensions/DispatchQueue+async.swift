//
//  DispatchQueue+async.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 02.11.20.
//

import Foundation

extension DispatchQueue {
    func asyncAfter(_ delay: Double, _ block: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: block)
    }
}
