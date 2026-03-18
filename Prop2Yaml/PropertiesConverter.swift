//
//  PropertiesConverter.swift
//  Prop2Yaml
//
//  Created by Vladimir Kolev on 13.03.26.
//

import Foundation

enum PropertiesConverter {
    
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
    
}
