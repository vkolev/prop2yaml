//
//  PropertiesConverter.swift
//  Prop2Yaml
//
//  Created by Vladimir Kolev on 13.03.26.
//

import Foundation

enum PropertiesConverter {
    
    // MARK: - Properties → YAML
    
    static func convert(_ input: String) -> AttributedString {
        var root = YAMLNode.mapping([])
        var pendingComments: [String] = []
        
        
        for rawLine in input.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            
            // Blank line — preserve as a blank separator between sections
            if line.isEmpty {
                pendingComments.append("")
                continue
            }
            
            // Comment line: # or legacy ! prefix
            if line.hasPrefix("#") || line.hasPrefix("!") {
                let comment = line.hasPrefix("!")
                ? "# \(line.dropFirst().trimmingCharacters(in: .whitespaces))"
                : line
                pendingComments.append(comment)
                continue
            }
            
            // Key=Value — split only on the FIRST '=' so values may contain '='
            guard let eqIdx = line.firstIndex(of: "=") else {
                pendingComments.append("# \(line)")   // unrecognised line -> comment
                continue
            }
            
            let key   = String(line[line.startIndex..<eqIdx]).trimmingCharacters(in: .whitespaces)
            let value = String(line[line.index(after: eqIdx)...]).trimmingCharacters(in: .whitespaces)
            let parts = key.components(separatedBy: ".").filter { !$0.isEmpty }
            guard !parts.isEmpty else { continue }
            
            // Attach accumulated comments to the first segment of this new key
            root.insert(parts: parts, value: value, comments: pendingComments)
            pendingComments = []
        }
        
        // Render and append any trailing comments / blank lines
        var outputLines: [String] = []
        root.render(into: &outputLines, indent: 0)
        outputLines.append(contentsOf: pendingComments)
        
        // Trim leading/trailing blank lines
        return AttributedString(outputLines
            .drop(while: { $0.isEmpty })
            .reversed()
            .drop(while: { $0.isEmpty })
            .reversed()
            .joined(separator: "\n"))
    }
    
    // MARK: - YAML → Properties
    
    static func convertYAMLToProperties(_ input: String) -> AttributedString {
        let lines = input.components(separatedBy: .newlines)
        var result: [String] = []
        var keyStack: [(indent: Int, key: String)] = []
        
        for rawLine in lines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)
            
            // Blank lines and comments pass through
            if trimmed.isEmpty {
                result.append("")
                continue
            }
            if trimmed.hasPrefix("#") {
                result.append(trimmed)
                continue
            }
            
            // Calculate indentation level
            let indent = rawLine.prefix(while: { $0 == " " }).count
            
            // Pop keys that are at the same or deeper indentation
            while let last = keyStack.last, last.indent >= indent {
                keyStack.removeLast()
            }
            
            // Parse "key: value" or "key:"
            guard let colonIdx = trimmed.firstIndex(of: ":") else { continue }
            
            let key = String(trimmed[trimmed.startIndex..<colonIdx])
                .trimmingCharacters(in: .whitespaces)
            let afterColon = String(trimmed[trimmed.index(after: colonIdx)...])
                .trimmingCharacters(in: .whitespaces)
            
            keyStack.append((indent: indent, key: key))
            
            if afterColon.isEmpty || afterColon == "{}" {
                // Parent key or empty mapping — no property line emitted
                continue
            }
            
            // Build the dotted key path from the stack
            let fullKey = keyStack.map(\.key).joined(separator: ".")
            let value = unquoteYAMLScalar(afterColon)
            result.append("\(fullKey)=\(value)")
        }
        
        // Trim leading/trailing blank lines
        let output = result
            .drop(while: { $0.isEmpty })
            .reversed()
            .drop(while: { $0.isEmpty })
            .reversed()
            .joined(separator: "\n")
        
        return AttributedString(output)
    }
    
    /// Removes YAML quoting from a scalar value.
    private static func unquoteYAMLScalar(_ value: String) -> String {
        // Double-quoted
        if value.hasPrefix("\"") && value.hasSuffix("\"") && value.count >= 2 {
            let inner = String(value.dropFirst().dropLast())
            return inner
                .replacingOccurrences(of: "\\\"", with: "\"")
                .replacingOccurrences(of: "\\\\", with: "\\")
        }
        // Single-quoted
        if value.hasPrefix("'") && value.hasSuffix("'") && value.count >= 2 {
            return String(value.dropFirst().dropLast())
                .replacingOccurrences(of: "''", with: "'")
        }
        return value
    }
}
