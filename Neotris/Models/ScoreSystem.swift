//
//  ScoreSystem.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI

// Scoring system
struct ScoreSystem {
    var score: Int = 0
    var highScore: Int = 0
    
    mutating func addScore(for lines: Int, level: Int) {
        // Enhanced Classic Tetris scoring with level multiplier
        let points: Int
        switch lines {
        case 1: points = 40 * level
        case 2: points = 100 * level
        case 3: points = 300 * level
        case 4: points = 1200 * level
        default: points = 0
        }
        
        score += points
        
        if score > highScore {
            highScore = score
        }
    }
    
    mutating func reset() {
        score = 0
    }
}
