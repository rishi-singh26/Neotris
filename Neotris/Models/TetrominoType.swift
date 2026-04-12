//
//  TetrominoType.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI

// Tetromino shape types
enum TetrominoType: String, CaseIterable, Codable {
    case i, o, t, j, l, s, z
    
    // Different colors for different tetromino types
    var color: Color {
        switch self {
        case .i: return .cyan
        case .o: return .yellow
        case .t: return .purple
        case .j: return .blue
        case .l: return .orange
        case .s: return .green
        case .z: return .red
        }
    }
    
    // Pivot block index for rotation (the block that stays fixed during rotation)
    var pivotIndex: Int {
        switch self {
        case .i: return 1 // Block(x: 1, y: 0)
        case .o: return 0 // unused; O doesn't rotate
        case .t: return 1 // Block(x: 1, y: 0)
        case .j: return 2 // Block(x: 1, y: 0)
        case .l: return 2 // Block(x: 1, y: 0)
        case .s: return 0 // Block(x: 1, y: 0)
        case .z: return 1 // Block(x: 1, y: 0)
        }
    }

    // Block configurations for each tetromino type
    var blocks: [Block] {
        switch self {
        case .i:
            return [Block(x: 0, y: 0), Block(x: 1, y: 0), Block(x: 2, y: 0), Block(x: 3, y: 0)]
        case .o:
            return [Block(x: 0, y: 0), Block(x: 1, y: 0), Block(x: 0, y: 1), Block(x: 1, y: 1)]
        case .t:
            return [Block(x: 0, y: 0), Block(x: 1, y: 0), Block(x: 2, y: 0), Block(x: 1, y: 1)]
        case .j:
            return [Block(x: 0, y: 1), Block(x: 0, y: 0), Block(x: 1, y: 0), Block(x: 2, y: 0)]
        case .l:
            return [Block(x: 2, y: 1), Block(x: 0, y: 0), Block(x: 1, y: 0), Block(x: 2, y: 0)]
        case .s:
            return [Block(x: 1, y: 0), Block(x: 2, y: 0), Block(x: 0, y: 1), Block(x: 1, y: 1)]
        case .z:
            return [Block(x: 0, y: 0), Block(x: 1, y: 0), Block(x: 1, y: 1), Block(x: 2, y: 1)]
        }
    }
}
