//
//  GameLevel.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import Foundation

// Enhanced Game level and speed
struct GameLevel: Codable {
    var level: Int
    var linesCleared: Int
    var maxLevel: Int = 15 // Maximum level cap
    
    // Enhanced drop speed calculation with more significant speed increases
    var dropSpeed: Double {
        // Exponential speed increase formula
        // Level 1: 1.0 second
        // Level 5: ~0.5 seconds
        // Level 10: ~0.25 seconds
        // Level 15: ~0.1 seconds
        return max(0.1, 1.0 / (1.0 + 0.15 * Double(level - 1)))
    }
    
    // Return a percentage (0-100) of how fast the game is currently
    var speedPercentage: Int {
        // Convert dropSpeed to a percentage where 1.0 is 0% and 0.1 is 100%
        return min(100, max(0, Int((1.0 - dropSpeed) * 111)))
    }
    
    init() {
        self.level = 1
        self.linesCleared = 0
    }
    
    mutating func addLines(_ count: Int) -> Bool {
        linesCleared += count
        
        // New level progression: level up every 5 lines for faster progression
        let newLevel = min(maxLevel, (linesCleared / 5) + 1)
        
        // Check if we leveled up
        let didLevelUp = newLevel > level
        level = newLevel
        
        return didLevelUp
    }
    
    // Lines needed to reach next level
    var linesToNextLevel: Int {
        let nextLevelLines = level * 5
        return nextLevelLines - linesCleared
    }
}
