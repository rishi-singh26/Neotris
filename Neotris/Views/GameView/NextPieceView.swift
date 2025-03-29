//
//  NextPieceView.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI

// Next piece preview view
struct NextPieceView: View {
    var tetromino: Tetromino?
    
    var body: some View {
        ZStack {
            // Background
            Color.black
            
            if let next = tetromino {
                // Draw the next tetromino
                ForEach(next.blocks, id: \.self) { block in
                    Rectangle()
                        .fill(next.type.color)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                        .offset(
                            x: CGFloat(block.x - 1) * 15,
                            y: CGFloat(block.y - 1) * 15
                        )
                }
            }
        }
    }
}

#Preview {
    NextPieceView(tetromino: Tetromino.init(type: .j, startPosition: (x: 0, y: 0)))
}
