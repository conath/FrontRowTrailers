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
    var onQuit: (() -> ())? = nil
    
    class Coordinator: NSObject {
        var parent: KeyEventHandling
        
        init(_ parent: KeyEventHandling) {
            self.parent = parent
            super.init()
            
            var localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
                if !self.handleKeyDown(with: event) {
                    return event
                } else {
                    return nil
                }
            }
        }
        
        
        // TODO: Add Esc. button
        
        func handleKeyDown(with event: NSEvent) -> Bool {
            let noModifier: NSEvent.ModifierFlags = NSEvent.ModifierFlags(rawValue: 10486016)
            if event.modifierFlags == noModifier {
                switch Int(event.keyCode) {
                case kVK_UpArrow:
                    parent.onUpArrow?()
                    break
                case kVK_DownArrow:
                    parent.onDownArrow?()
                    break
                default:
                    return false
                }
                return true
            } else
            /// `cmd-q` ?
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == NSEvent.ModifierFlags.command.rawValue &&
                        Int(event.keyCode) == kVK_ANSI_Q {
                parent.onQuit?()
                return true
            } else {
                return false
            }
        }
    }
    
    class KeyView: NSView {}

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
    }
}

struct TestKeyboardEventHandling: View {
    var body: some View {
        Text("Hello, World!")
            .background(KeyEventHandling())
    }
}
