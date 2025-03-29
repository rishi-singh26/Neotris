//
//  Tetromino.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import Foundation

// Tetromino model
struct Tetromino {
    var type: TetrominoType
    var blocks: [Block]
    var position: (x: Int, y: Int)
    var rotation: Int = 0
    
    init(type: TetrominoType, startPosition: (x: Int, y: Int)) {
        self.type = type
        self.blocks = type.blocks
        self.position = startPosition
    }
    
    // Get the absolute positions of blocks
    func absoluteBlockPositions() -> [Block] {
        return blocks.map { Block(x: $0.x + position.x, y: $0.y + position.y) }
    }
    
    // Rotate the tetromino
    mutating func rotate(clockwise: Bool = true) {
        // O piece doesn't rotate
        if type == .o { return }
        
        // Find center of rotation
        let centerX = blocks.map { $0.x }.reduce(0, +) / 4
        let centerY = blocks.map { $0.y }.reduce(0, +) / 4
        
        // Rotate each block around the center
        blocks = blocks.map { block in
            let x = block.x - centerX
            let y = block.y - centerY
            
            if clockwise {
                return Block(x: centerX + y, y: centerY - x)
            } else {
                return Block(x: centerX - y, y: centerY + x)
            }
        }
        
        rotation = (rotation + (clockwise ? 1 : -1) + 4) % 4
    }
}
