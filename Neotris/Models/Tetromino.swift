//
//  Tetromino.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import Foundation

// Tetromino model
struct Tetromino: Codable {
    var type: TetrominoType
    var blocks: [Block]
    var position: (x: Int, y: Int)
    var rotation: Int = 0
    
    init(type: TetrominoType, startPosition: (x: Int, y: Int)) {
        self.type = type
        self.blocks = type.blocks
        self.position = startPosition
    }
    
    // For Codable conformance
    enum CodingKeys: String, CodingKey {
        case type, blocks, positionX, positionY, rotation
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(TetrominoType.self, forKey: .type)
        blocks = try container.decode([Block].self, forKey: .blocks)
        let x = try container.decode(Int.self, forKey: .positionX)
        let y = try container.decode(Int.self, forKey: .positionY)
        position = (x: x, y: y)
        rotation = try container.decode(Int.self, forKey: .rotation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(blocks, forKey: .blocks)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(rotation, forKey: .rotation)
    }
    
    // Get the absolute positions of blocks
    func absoluteBlockPositions() -> [Block] {
        return blocks.map { Block(x: $0.x + position.x, y: $0.y + position.y) }
    }
    
    // Rotate the tetromino
    mutating func rotate(clockwise: Bool = true) {
        // O piece doesn't rotate
        if type == .o { return }
        
        // For I piece, we need special handling since it doesn't have a true center
        if type == .i {
            let pivotIndex = 1 // Use the second block as pivot for I piece
            let pivotX = blocks[pivotIndex].x
            let pivotY = blocks[pivotIndex].y
            
            blocks = blocks.map { block in
                let relX = block.x - pivotX
                let relY = block.y - pivotY
                
                if clockwise {
                    return Block(x: pivotX + relY, y: pivotY - relX)
                } else {
                    return Block(x: pivotX - relY, y: pivotY + relX)
                }
            }
        } else {
            // For other pieces, we can use the center of rotation calculation
            // But we need to handle the math differently because we have integers
            
            // Find a suitable pivot point (using the first block as reference)
            let pivotX = blocks[0].x
            let pivotY = blocks[0].y
            
            blocks = blocks.map { block in
                let relX = block.x - pivotX
                let relY = block.y - pivotY
                
                if clockwise {
                    return Block(x: pivotX + relY, y: pivotY - relX)
                } else {
                    return Block(x: pivotX - relY, y: pivotY + relX)
                }
            }
        }
        
        rotation = (rotation + (clockwise ? 1 : -1) + 4) % 4
    }
}
