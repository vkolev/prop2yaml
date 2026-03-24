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
    @State private var yamlTextStr: String = ""
    @State private var showLineNumbers: Bool = true
    @State private var fontSize: CGFloat = 13
    
    var body: some View {
        VStack(spacing: 0) {
            ToolbarView(
                showLineNumbers: $showLineNumbers,
                fontSize: $fontSize,
                onClear: {
                    propertiesText = AttributedString("")
                    yamlText = AttributedString("")
                    propertiesTextStr = ""
                    yamlTextStr = ""
                },
                onConvertToYAML: convertPropertiesToYAML,
                onConvertToProperties: convertYAMLToProperties
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
                        set: { propertiesTextStr = String($0.characters) }
                    ),
                    isEditable: true,
                    showLineNumbers: showLineNumbers,
                    fontSize: fontSize,
                    placeholder: "# Example\napp.name=My Application\napp.version=1.0.0\nserver.host=localhost\nserver.port=8080"
                ).id(UUID())
                
                PaneDivider()
                
                EditorPane(
                    title: "YAML",
                    subtitle: "Paste YAML or view converted output",
                    icon: "arrow.right.doc.on.clipboard",
                    accentColor: .green,
                    text: Binding(
                        get: { yamlText },
                        set: { yamlTextStr = String($0.characters) }
                    ),
                    isEditable: true,
                    showLineNumbers: showLineNumbers,
                    fontSize: fontSize,
                    placeholder: "# YAML output will appear here\n# after conversion"
                ).id(UUID())
            }
            .layoutPriority(1)
            
            Divider()
            
            StatusBar(
                propertiesText: String(propertiesText.characters),
                yamlText: String(yamlText.characters)
            )
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onChange(of: propertiesText) { _, _ in convertPropertiesToYAML() }
    }
    
    /// Properties → YAML
    private func convertPropertiesToYAML() {
        propertiesText = SyntaxHighlighter
            .highlightProperties(propertiesTextStr)
        
        guard !propertiesTextStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            yamlText = AttributedString("")
            yamlTextStr = ""
            return
        }
        
        let converted = PropertiesConverter.convert(propertiesTextStr)
        let convertedStr = String(converted.characters)
        yamlTextStr = convertedStr
        yamlText = SyntaxHighlighter.highlightYAML(convertedStr)
    }
    
    /// YAML → Properties (triggered by button only)
    private func convertYAMLToProperties() {
        yamlText = SyntaxHighlighter
            .highlightYAML(yamlTextStr)
        
        guard !yamlTextStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            propertiesText = AttributedString("")
            propertiesTextStr = ""
            return
        }
        
        let converted = PropertiesConverter.convertYAMLToProperties(yamlTextStr)
        let convertedStr = String(converted.characters)
        propertiesTextStr = convertedStr
        propertiesText = SyntaxHighlighter.highlightProperties(convertedStr)
    }
}

#Preview {
    ContentView()
}
