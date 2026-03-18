//
//  YAMLNode.swift
//  Prop2Yaml
//
//  Created by Vladimir Kolev on 13.03.26.
//
import Foundation

enum YAMLNode {
    case mapping([(key: String, comments: [String], node: YAMLNode)])
    case scalar(String)
    
    // MARK: Insert
    
    mutating func insert(parts: [String], value: String, comments: [String]) {
        guard case .mapping(var children) = self else { return }
        
        let head = parts[0]
        let tail = Array(parts.dropFirst())
        
        if let idx = children.firstIndex(where: { $0.key == head }) {
            if tail.isEmpty {
                // Overwrite scalar; keep previously attached comments
                children[idx] = (key: head,
                                 comments: children[idx].comments,
                                 node: .scalar(value))
            } else {
                // If the existing node is already a scalar being extended into a
                // mapping (e.g. `spring=x` followed by `spring.datasource.url=y`),
                // promote it to an empty mapping before recursing.
                if case .scalar = children[idx].node {
                    children[idx].node = .mapping([])
                }
                children[idx].node.insert(parts: tail, value: value, comments: [])
            }
        } else {
            // New key at this level — attach the pending comments here
            if tail.isEmpty {
                children.append((key: head, comments: comments, node: .scalar(value)))
            } else {
                var child = YAMLNode.mapping([])
                child.insert(parts: tail, value: value, comments: [])
                children.append((key: head, comments: comments, node: child))
            }
        }
        
        self = .mapping(children)
    }
    
    // MARK: Render
    
    func render(into lines: inout [String], indent: Int) {
        guard case .mapping(let children) = self else { return }
        let pad = String(repeating: " ", count: indent)
        
        for (key, comments, node) in children {
            // Emit any preceding comments / blank-line separators at this indent level
            for comment in comments {
                lines.append(comment.isEmpty ? "" : "\(pad)\(comment)")
            }
            
            switch node {
            case .scalar(let value):
                lines.append("\(pad)\(key): \(yamlScalar(value))")
                
            case .mapping(let sub) where sub.isEmpty:
                lines.append("\(pad)\(key): {}")
                
            case .mapping:
                lines.append("\(pad)\(key):")
                node.render(into: &lines, indent: indent + 2)
            }
        }
    }
}

private func yamlScalar(_ value: String) -> String {
    if value.isEmpty { return "''" }
    
    let boolLike = ["true", "false", "yes", "no", "on", "off", "null", "~"]
    let needsQuotes =
    boolLike.contains(value.lowercased())   ||
    Double(value) != nil                    ||
    value.hasPrefix("\"") || value.hasPrefix("'")  ||
    value.hasPrefix("{")  || value.hasPrefix("[")  ||
    value.hasPrefix("|")  || value.hasPrefix(">")  ||
    value.hasPrefix("*")  || value.hasPrefix("&")  ||
    value.hasPrefix("!")  || value.hasPrefix("%")  ||
    value.contains(": ")  || value.contains(" #")  ||
    value.hasPrefix(" ")  || value.hasSuffix(" ")  ||
    value.contains("\n")
    
    guard needsQuotes else { return value }
    
    let escaped = value
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
    return "\"\(escaped)\""
}
