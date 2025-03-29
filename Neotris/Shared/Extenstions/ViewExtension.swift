//
//  ViewExtension.swift
//  Neotris
//
//  Created by Rishi Singh on 11/03/25.
//

import SwiftUI

// Extension to add glow border effect to text
extension View {
    func glowBorder(color: Color, lineWidth: CGFloat) -> some View {
        self.overlay(
            self.blur(radius: 4)
                .opacity(0.7)
                .foregroundColor(color)
        )
        .overlay(
            self.blur(radius: 2)
                .opacity(0.3)
                .foregroundColor(color)
        )
        .overlay(
            self
        )
    }
}
