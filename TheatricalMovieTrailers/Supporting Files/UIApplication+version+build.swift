//
//  UIApplication+version+build.swift
//  PresentAnything
//
//  Created by Christoph Parstorfer on 22.08.20.
//  Copyright © 2020 Christoph Parstorfer. All rights reserved.
//

import UIKit

extension UIApplication {
    /// Returns the `CFBundleShortVersionString` from *Info.plist*.
    var version: String {
        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            fatalError("Couldn't find CFBundleShortVersionString in Info.plist")
        }
        return appVersion
    }
    /// Returns the `CFBundleVersion` from *Info.plist*.
    var build: String {
        guard let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            fatalError("Couldn't find CFBundleVersion in Info.plist")
        }
        return build
    }
}
