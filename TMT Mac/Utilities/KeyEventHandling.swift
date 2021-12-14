//
//  KeyEventHandling.swift
//  Theatrical Trailers
//
//  Created by Christoph Parstorfer on 13.12.21.
//

import AppKit
import Carbon.HIToolbox
import SwiftUI

struct KeyEventHandling: NSViewRepresentable {
    var onUpArrow: (() -> ())? = nil
    var onDownArrow: (() -> ())? = nil
    
    class Coordinator: NSObject {
        var parent: KeyEventHandling
        
        init(_ parent: KeyEventHandling) {
            self.parent = parent
        }
    }
    
    class KeyView: NSView {
        var onUpArrow: (() -> ())? = nil
        var onDownArrow: (() -> ())? = nil
        
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {
            let noModifier: NSEvent.ModifierFlags = NSEvent.ModifierFlags(rawValue: 10486016)
            if event.modifierFlags == noModifier {
                switch Int(event.keyCode) {
                case kVK_UpArrow:
                    onUpArrow?()
                    break
                case kVK_DownArrow:
                    onDownArrow?()
                    break
                default:
                    super.keyDown(with: event)
                }
            } else {
                super.keyDown(with: event)
            }
        }
    }

    func makeNSView(context: Context) -> KeyView {
        let view = KeyView()
        DispatchQueue.main.asyncAfter(1) { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        updateNSView(view, context: context)
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateNSView(_ nsView: KeyView, context: Context) {
        nsView.window?.makeFirstResponder(nsView)
        context.coordinator.parent = self
        nsView.onUpArrow = context.coordinator.parent.onUpArrow
        nsView.onDownArrow = context.coordinator.parent.onDownArrow
    }
}

struct TestKeyboardEventHandling: View {
    var body: some View {
        Text("Hello, World!")
            .background(KeyEventHandling())
    }
}
