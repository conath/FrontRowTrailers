//
//  Undefined.swift
//  MovieTrailers
//
//  Created by Chris on 25.06.20.
//

import Foundation

func undefined<T>(_ message: String = "") -> T {
    fatalError(message)
}
