//
//  TetrisGameModel.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI
import Combine

class TetrisGameModel: ObservableObject {
    // Game board dimensions
    let boardWidth = 10
    let boardHeight = 20
    
    // Game state
    @Published var gameState: GameState = .waiting
    @Published var gameBoard: [[Color?]]
    @Published var currentTetromino: Tetromino?
    @Published var nextTetromino: Tetromino?
    @Published var gameLevel = GameLevel()
    @Published var scoreSystem = ScoreSystem()
    @Published var showLevelUpAnimation: Bool = false
    
    // Timer for game loop
    private var gameTimer: AnyCancellable?
    private var lastMoveDownTime: Date = Date()
    
    // Initialize game
    init() {
        self.gameBoard = Array(repeating: Array(repeating: nil, count: boardWidth), count: boardHeight)
        resetGame()
    }
    
    // Reset the game
    func resetGame() {
        gameBoard = Array(repeating: Array(repeating: nil, count: boardWidth), count: boardHeight)
        gameState = .waiting
        gameLevel = GameLevel()
        scoreSystem.reset()
        generateNewTetromino()
        generateNextTetromino()
        showLevelUpAnimation = false
    }
    
    // Start the game
    func startGame() {
        guard gameState != .playing else { return }
        
        gameState = .playing
        
        // Set up game loop
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.gameLoop()
            }
    }
    
    // Pause the game
    func pauseGame() {
        if gameState == .playing {
            gameState = .paused
            gameTimer?.cancel()
        } else if gameState == .paused {
            resumeGame()
        }
    }
    
    // Resume the game
    func resumeGame() {
        guard gameState == .paused else { return }
        
        gameState = .playing
        
        // Set up game loop again
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.gameLoop()
            }
        
        // Reset the last move down time to prevent immediate movement
        lastMoveDownTime = Date()
    }
    
    // End the game
    func endGame() {
        gameState = .gameOver
        gameTimer?.cancel()
    }
    
    // Game loop
    private func gameLoop() {
        guard gameState == .playing, let current = currentTetromino else { return }
        
        // Check if it's time to move the piece down based on current level's drop speed
        if Date().timeIntervalSince(lastMoveDownTime) >= gameLevel.dropSpeed {
            lastMoveDownTime = Date()
            
            // Try to move down
            if canMove(current, to: (current.position.x, current.position.y + 1)) {
                currentTetromino?.position.y += 1
            } else {
                // Place the tetromino on the board
                placeTetromino()
                
                // Check for completed lines
                checkForCompletedLines()
                
                // Generate a new tetromino
                generateNewTetromino()
                
                // Check if game is over
                if isGameOver() {
                    endGame()
                }
            }
        }
    }
    
    // Generate a new tetromino
    private func generateNewTetromino() {
        if let next = nextTetromino {
            currentTetromino = next
        } else {
            // Start position at the top center of the board
            let startX = (boardWidth / 2) - 1
            let type = TetrominoType.allCases.randomElement()!
            currentTetromino = Tetromino(type: type, startPosition: (x: startX, y: 0))
        }
        
        generateNextTetromino()
    }
    
    // Generate the next tetromino
    private func generateNextTetromino() {
        let startX = (boardWidth / 2) - 1
        let type = TetrominoType.allCases.randomElement()!
        nextTetromino = Tetromino(type: type, startPosition: (x: startX, y: 0))
    }
    
    // Check if tetromino can move to a new position
    func canMove(_ tetromino: Tetromino, to newPosition: (x: Int, y: Int)) -> Bool {
        var movedTetromino = tetromino
        movedTetromino.position = newPosition
        
        for block in movedTetromino.absoluteBlockPositions() {
            // Check if block is out of bounds
            if block.x < 0 || block.x >= boardWidth || block.y < 0 || block.y >= boardHeight {
                return false
            }
            
            // Check if block overlaps with existing blocks on the board
            if block.y >= 0 && block.y < boardHeight && block.x >= 0 && block.x < boardWidth,
               gameBoard[block.y][block.x] != nil {
                return false
            }
        }
        
        return true
    }
    
    // Check if tetromino can rotate
    func canRotate(_ tetromino: Tetromino) -> Bool {
        var rotatedTetromino = tetromino
        rotatedTetromino.rotate()
        
        return canMove(rotatedTetromino, to: tetromino.position)
    }
    
    // Place the current tetromino on the board
    private func placeTetromino() {
        guard let current = currentTetromino else { return }
        
        for block in current.absoluteBlockPositions() {
            // Ensure the block is within the board bounds
            if block.y >= 0 && block.y < boardHeight && block.x >= 0 && block.x < boardWidth {
                gameBoard[block.y][block.x] = current.type.color
            }
        }
    }
    
    // Check for completed lines and remove them
    private func checkForCompletedLines() {
        var completedLines = 0
        
        // Check each row from bottom to top
        for y in (0..<boardHeight).reversed() {
            if gameBoard[y].allSatisfy({ $0 != nil }) {
                // Line is complete, remove it
                for j in (1...y).reversed() {
                    gameBoard[j] = gameBoard[j-1]
                }
                // Clear the top line
                gameBoard[0] = Array(repeating: nil, count: boardWidth)
                completedLines += 1
            }
        }
        
        // Update score and level
        if completedLines > 0 {
            // Add score with level multiplier
            scoreSystem.addScore(for: completedLines, level: gameLevel.level)
            
            // Add lines and check if level increased
            let didLevelUp = gameLevel.addLines(completedLines)
            
            // Show level up animation if needed
            if didLevelUp {
                showLevelUpAnimation = true
                
                // Hide the animation after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.showLevelUpAnimation = false
                }
            }
        }
    }
    
    // Check if the game is over (pieces stack to the top)
    private func isGameOver() -> Bool {
        // Check if the top row has any blocks
        return gameBoard[0].contains(where: { $0 != nil })
    }
    
    // User input actions
    func moveLeft() {
        guard gameState == .playing, let current = currentTetromino else { return }
        
        if canMove(current, to: (current.position.x - 1, current.position.y)) {
            currentTetromino?.position.x -= 1
        }
    }
    
    func moveRight() {
        guard gameState == .playing, let current = currentTetromino else { return }
        
        if canMove(current, to: (current.position.x + 1, current.position.y)) {
            currentTetromino?.position.x += 1
        }
    }
    
    func rotate() {
        guard gameState == .playing, let current = currentTetromino else { return }
        
        if canRotate(current) {
            currentTetromino?.rotate()
        }
    }
    
    func moveDown() {
        guard gameState == .playing, let current = currentTetromino else { return }
        
        if canMove(current, to: (current.position.x, current.position.y + 1)) {
            currentTetromino?.position.y += 1
        }
    }
    
    func hardDrop() {
        guard gameState == .playing, let current = currentTetromino else { return }
        
        var newY = current.position.y
        
        // Find the lowest position the tetromino can go
        while canMove(current, to: (current.position.x, newY + 1)) {
            newY += 1
        }
        
        // Move the tetromino to that position
        if newY != current.position.y {
            currentTetromino?.position.y = newY
            
            // Update last move down time to prevent immediate movement
            lastMoveDownTime = Date()
        }
    }
}
