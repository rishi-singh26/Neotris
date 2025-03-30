//
//  GameState.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import Foundation

// Game state
enum GameState: String, CaseIterable, Codable {
    case waiting = "waiting"
    case playing = "playing"
    case paused = "paused"
    case gameOver = "gameOver"
}
