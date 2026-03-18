//
//  EditorPane.swift
//  Prop2Yaml
//
//  Created by Vladimir Kolev on 13.03.26.
//
import SwiftUI
import Foundation
import STTextViewSwiftUI
import STTextViewSwiftUICommon

struct EditorPane: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    @Binding var text: AttributedString
    let isEditable: Bool
    let showLineNumbers: Bool
    let fontSize: CGFloat
    let placeholder: String
    @State private var fontToken = UUID()
    
    @State private var isCopied = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(accentColor)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !isEditable {
                    Button {
                        copyToClipboard()
                    } label: {
                        Label(
                            isCopied ? "Copied!" : "Copy",
                            systemImage: isCopied ? "checkmark" : "doc.on.doc"
                        )
                        .font(.system(size: 11, weight: .medium))
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(isCopied ? .green : .secondary)
                    .animation(.easeInOut(duration: 0.2), value: isCopied)
                } else {
                    Button {
                        text = AttributedString()
                    } label: {
                        Label("Clear", systemImage: "xmark.circle")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                    .disabled(text.characters.isEmpty)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            if showLineNumbers {
                TextView(
                    text: $text,
                    options: [
                        .wrapLines,
                        .highlightSelectedLine,
                        .showLineNumbers
                    ]
                )
                .textViewFont(
                    .monospacedSystemFont(ofSize: fontSize, weight: .regular)
                )
                .id(fontToken)
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
                    fontToken = UUID()
                }
                .clipped()
            } else {
                TextView(
                    text: $text,
                    options: [.wrapLines, .highlightSelectedLine]
                )
                .textViewFont(
                    .monospacedSystemFont(ofSize: fontSize, weight: .regular)
                )
                .id(fontToken)
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
                    fontToken = UUID()
                }
                .clipped()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(String(text.characters), forType: .string)
        isCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { isCopied = false }
    }
}
