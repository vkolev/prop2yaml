//
//  StatusBar.swift
//  Prop2Yaml
//
//  Created by Vladimir Kolev on 13.03.26.
//

import Foundation
import SwiftUI

struct StatusBar: View {
    let propertiesText: String
    let yamlText: String
    
    var inputLines: Int  { propertiesText.isEmpty ? 0 : propertiesText.components(separatedBy: .newlines).count }
    var outputLines: Int { yamlText.isEmpty ? 0 : yamlText.components(separatedBy: .newlines).count }
    var inputKeys: Int   {
        propertiesText.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty && !$0.hasPrefix("#") && $0.contains("=") }
            .count
    }
    
    var body: some View {
        HStack(spacing: 16) {
            StatusItem(icon: "doc.text", label: "Input", value: "\(inputLines) lines · \(inputKeys) keys")
            Divider().frame(height: 12)
            StatusItem(icon: "checkmark.circle", label: "Output", value: "\(outputLines) lines")
            Spacer()
            Text("Live conversion enabled")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct StatusItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Text("\(label):")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}
