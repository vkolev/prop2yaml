//
//  PaneDivider.swift
//  Prop2Yaml
//
//  Created by Vladimir Kolev on 13.03.26.
//
import Foundation
import SwiftUI

struct PaneDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(NSColor.separatorColor))
            .frame(width: 1)
            .overlay(
                // Drag handle dots
                VStack(spacing: 4) {
                    ForEach(0..<5) { _ in
                        Circle()
                            .fill(Color.secondary.opacity(0.35))
                            .frame(width: 3, height: 3)
                    }
                }
            )
    }
}
