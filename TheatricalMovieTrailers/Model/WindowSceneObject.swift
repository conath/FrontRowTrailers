//
//  WindowSceneObject.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 30.10.20.
//

import Combine
import UIKit

/// Wraps `UIWindowScene` as an `ObservableObject` to be passed to SwiftUI views.
class WindowSceneObject: ObservableObject {
    @Published var windowScene: UIWindowScene?
    
    init(_ windowScene: UIWindowScene?) {
        self.windowScene = windowScene
    }
}
