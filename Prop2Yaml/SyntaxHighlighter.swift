//
//  SyntaxHighlighter.swift
//  Prop2Yaml
//
//  Created by Vladimir Kolev on 18.03.26.
//

import Foundation
import SwiftUI

enum SyntaxHighlighter {
    static func highlightProperties(_ input: String) -> AttributedString {
        var result = AttributedString()
        let monoFont = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        
        for line in input.components(separatedBy: .newlines) {
            var attrLine = AttributedString(line + "\n")
            attrLine.font = monoFont
            attrLine.foregroundColor = .labelColor
            
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("#") || trimmed.hasPrefix(";") {
                attrLine.foregroundColor = .systemGreen
            } else if let eqIdx = line.firstIndex(of: "=") {
                let keyRange = line.startIndex..<eqIdx
                let valRange = line.index(after: eqIdx)..<line.endIndex
                
                if let attrKeyRange = Range(
                    NSRange(keyRange, in: line),
                    in: attrLine
                ) {
                    attrLine[attrKeyRange].foregroundColor = .systemBlue
                }
                
                if let attrValueRange = Range(NSRange(valRange, in: line), in: attrLine) {
                    attrLine[attrValueRange].foregroundColor = .labelColor
                }
            }
            result.append(attrLine)
        }
        return result
    }
    
    static func highlightYAML(_ input: String) -> AttributedString {
        var result = AttributedString()
        let monoFont = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        
        for line in input.components(separatedBy: .newlines) {
            var attrLine = AttributedString(line + "\n")
            attrLine.font = monoFont
            attrLine.foregroundColor = .labelColor
            
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("#") {
                // Comment — green
                attrLine.foregroundColor = .systemGreen
                
            } else if let colonIdx = line.firstIndex(of: ":") {
                // Key — orange, value — primary
                let keyRange = line.startIndex..<colonIdx
                let afterColon = line.index(after: colonIdx)
                let valRange = afterColon..<line.endIndex
                
                if let attrKeyRange = Range(NSRange(keyRange, in: line), in: attrLine) {
                    attrLine[attrKeyRange].foregroundColor = .systemOrange
                }
                if let attrValRange = Range(NSRange(valRange, in: line), in: attrLine) {
                    attrLine[attrValRange].foregroundColor = .labelColor
                }
            }
            
            result.append(attrLine)
        }
        
        return result
    }
}
