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
    var onEsc: (() -> ())? = nil
    var onQuit: (() -> ())? = nil
    
    class Coordinator: NSObject {
        var parent: KeyEventHandling
        var keyHandler: Any? = nil
        
        init(_ parent: KeyEventHandling) {
            self.parent = parent
            super.init()
            
            keyHandler = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
                if self.handleKeyDown(with: event) {
                    /// we handled it, don't send it to the system
                    return nil
                } else {
                    /// not handled, send back to event system
                    return event
                }
            }
        }
        
        deinit {
            if let keyHandler = keyHandler {
                NSEvent.removeMonitor(keyHandler)
            }
            keyHandler = nil
        }
        
        func handleKeyDown(with event: NSEvent) -> Bool {
            let modifierFlags = event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
            let noModifier: UInt = 0
            let arrowKeyModifierFlag: UInt = 10485760
            if modifierFlags == noModifier || modifierFlags == arrowKeyModifierFlag {
                switch Int(event.keyCode) {
                case kVK_UpArrow:
                    parent.onUpArrow?()
                    break
                case kVK_DownArrow:
                    parent.onDownArrow?()
                    break
                case kVK_Escape:
                    parent.onEsc?()
                    break
                default:
                    return false
                }
                return true
            } else
            /// `cmd-q` ?
            if modifierFlags == NSEvent.ModifierFlags.command.rawValue &&
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
