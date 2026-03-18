//
//  ContentView.swift
//  Prop2Yaml
//
//  Created by Vladimir Kolev on 13.03.26.
//

import SwiftUI

struct ContentView: View {
    @State private var propertiesText = AttributedString("")
    @State private var propertiesTextStr: String = ""
    @State private var yamlText = AttributedString("")
    @State private var showLineNumbers: Bool = true
    @State private var fontSize: CGFloat = 13
    
    var body: some View {
        VStack(spacing: 0) {
            ToolbarView(
                showLineNumbers: $showLineNumbers,
                fontSize: $fontSize,
                onClear: { propertiesText = AttributedString(""); yamlText = AttributedString(); propertiesTextStr = "" },
                onConvert: convert
            )
            
            Divider()
            
            HStack(spacing: 0) {
                EditorPane(
                    title: "Properties",
                    subtitle: "Paste your .properties file here",
                    icon: "doc.text",
                    accentColor: .blue,
                    text: Binding(
                        get: { propertiesText },
                        set: { propertiesTextStr = String($0.characters )}
                    ),
                    isEditable: true,
                    showLineNumbers: showLineNumbers,
                    fontSize: fontSize,
                    placeholder: "# Example\napp.name=My Application\napp.version=1.0.0\nserver.host=localhost\nserver.port=8080"
                ).id(UUID())
                
                PaneDivider()
                
                EditorPane(
                    title: "YAML",
                    subtitle: "Converted output",
                    icon: "arrow.right.doc.on.clipboard",
                    accentColor: .green,
                    text: $yamlText,
                    isEditable: false,
                    showLineNumbers: showLineNumbers,
                    fontSize: fontSize,
                    placeholder: "# YAML output will appear here\n# after conversion"
                ).id(UUID())
            }
            .layoutPriority(1)  // ← tells VStack to give remaining space to panes, not expand them
            
            Divider()
            
            StatusBar(propertiesText: String(
                propertiesText.characters),
                      yamlText: String(yamlText.characters)
            )
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onChange(of: propertiesText) { _, _ in convert() }
    }
    
    private func convert() {
        propertiesText = SyntaxHighlighter
            .highlightProperties(propertiesTextStr)
        
        
        guard !propertiesTextStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            yamlText = ""
            return
        }
        
        yamlText = PropertiesConverter.convert(propertiesTextStr)
        yamlText = SyntaxHighlighter.highlightYAML(String(yamlText.characters))
    }
}

#Preview {
    ContentView()
}
