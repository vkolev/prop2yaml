//
//  ToolbarView.swift
//  Prop2Yaml
//
//  Created by Vladimir Kolev on 13.03.26.
//

import Foundation
import SwiftUI

struct ToolbarView: View {
    @Binding var showLineNumbers: Bool
    @Binding var fontSize: CGFloat
    let onClear: () -> Void
    let onConvert: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // App identity
            HStack(spacing: 8) {
                Image(systemName: "arrow.left.arrow.right.square.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.blue.gradient)
                Text("PropToYAML")
                    .font(.system(size: 14, weight: .bold))
            }
            
            Divider().frame(height: 20)
            
            // Font size stepper
            HStack(spacing: 4) {
                Button { fontSize = max(10, fontSize - 1) } label: {
                    Image(systemName: "textformat.size.smaller")
                }
                .buttonStyle(.borderless)
                .help("Decrease font size")
                
                Text("\(Int(fontSize))px")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 32)
                
                Button { fontSize = min(24, fontSize + 1) } label: {
                    Image(systemName: "textformat.size.larger")
                }
                .buttonStyle(.borderless)
                .help("Increase font size")
            }
            
            Divider().frame(height: 20)
            
            // Line numbers toggle
            Toggle(isOn: $showLineNumbers) {
                Label("Line Numbers", systemImage: "list.number")
                    .font(.system(size: 12))
            }
            .toggleStyle(.checkbox)
            
            Spacer()
            
            // Actions
            Button(role: .destructive, action: onClear) {
                Label("Clear", systemImage: "trash")
                    .font(.system(size: 12))
            }
            .buttonStyle(.borderless)
            .foregroundColor(.red.opacity(0.8))
            .help("Clear both panes")
            
            Button(action: onConvert) {
                Label("Convert", systemImage: "bolt.fill")
                    .font(.system(size: 12, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .help("Convert .properties to YAML")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
