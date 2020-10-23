//
//  UIResponder+currentResponder.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 23.10.20.
//

import UIKit

/// From https://stackoverflow.com/a/14135456/6870041
/// via https://www.vadimbulavin.com/how-to-move-swiftui-view-when-keyboard-covers-text-field/
extension UIResponder {
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    private static weak var _currentFirstResponder: UIResponder?

    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }

    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.superview?.convert(view.frame, to: nil)
    }
}
