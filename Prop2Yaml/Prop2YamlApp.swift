//
//  Prop2YamlApp.swift
//  Prop2Yaml
//
//  Created by Vladimir Kolev on 13.03.26.
//

import SwiftUI

@main
struct Prop2YamlApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowAccessor { window in
                    window.setContentSize(NSSize(width: 1100, height: 720))
                    window.minSize = NSSize(width: 600, height: 400)
                })
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .windowResizability(.automatic)
        .defaultSize(width: 1100, height: 720)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.callback(window)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
