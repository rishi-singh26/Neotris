//
//  SavedGameState.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

import Foundation

// Saved game state for resuming in-progress games
struct SavedGameState: Codable {
    var gameBoard: [[String?]] // We'll store color names instead of Color objects
    var currentTetromino: Tetromino?
    var nextTetromino: Tetromino?
    var gameLevel: GameLevel
    var scoreSystem: ScoreSystem
    var gameState: GameState
    var creationDate: Date
    var lastPlayedDate: Date
    var totalPlayTime: TimeInterval
}
