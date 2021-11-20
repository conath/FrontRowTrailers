//
//  NSApplication+version+build.swift
//  TMT Mac
//
//  Created by Christoph Parstorfer on 20.11.21.
//

import AppKit

extension NSApplication {
    /// Returns the `CFBundleShortVersionString` from *Info.plist*.
    static var version: String {
        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            fatalError("Couldn't find CFBundleShortVersionString in Info.plist")
        }
        return appVersion
    }
    /// Returns the `CFBundleVersion` from *Info.plist*.
    static var build: String {
        guard let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            fatalError("Couldn't find CFBundleVersion in Info.plist")
        }
        return build
    }
}
