//
//  Block.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import Foundation

// Each Tetromino piece is made up of 4 blocks
struct Block: Hashable, Codable {
    var x: Int
    var y: Int
}
