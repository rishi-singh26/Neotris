//
//  TetrisGameModel.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI
import Combine
import SwiftData

class TetrisGameModel: ObservableObject {
    static let shared = TetrisGameModel();
    // Game board dimensions
    let boardWidth = 10
    let boardHeight = 20
    
    // Game state
    @Published var gameState: GameState = .waiting
    @Published var gameBoard: [[Color?]]
    @Published var currentTetromino: Tetromino?
    @Published var nextTetromino: Tetromino?
    @Published var secondNextTetromino: Tetromino?
    @Published var gameLevel = GameLevel()
    @Published var scoreSystem = ScoreSystem()
    @Published var showLevelUpAnimation: Bool = false
    @AppStorage("gameSoundEnabled") var gameSoundEnabled: Bool = true
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled: Bool = true
    @AppStorage("ghostBlocksEnabled") var ghostBlocksEnabled: Bool = true
    @AppStorage("gameTheme") var gameTheme: Int = 0 // 0 -> System, 1 -> Light, 2 -> Dark
    
    // Added: Ghost piece position
    @Published var ghostPiecePosition: (x: Int, y: Int)? = nil
    
    // New: Track game creation time and play duration
    private var creationDate: Date
    private var lastPlayedDate: Date
    private var totalPlayTime: TimeInterval = 0
    private var sessionStartTime: Date?
    
    // Timer for game loop
    private var gameTimer: AnyCancellable?
    private var lastMoveDownTime: Date = Date()
    
    // SwiftData model context
    private var modelContext: ModelContext?
    
    // Initialize game
    init(modelContext: ModelContext? = nil) {
        self.gameBoard = Array(repeating: Array(repeating: nil, count: boardWidth), count: boardHeight)
        self.creationDate = Date()
        self.lastPlayedDate = Date()
        self.modelContext = modelContext
        resetGame()
    }
    
    // Initialize with saved game state
    init(savedState: SavedGameState, modelContext: ModelContext? = nil) {
        self.gameBoard = Array(repeating: Array(repeating: nil, count: savedState.gameBoard[0].count), count: savedState.gameBoard.count)
        self.modelContext = modelContext
        self.creationDate = savedState.creationDate
        self.lastPlayedDate = savedState.lastPlayedDate
        self.totalPlayTime = savedState.totalPlayTime
        
        // Initialize the game board with saved colors
        for y in 0..<savedState.gameBoard.count {
            for x in 0..<savedState.gameBoard[y].count {
                if let colorName = savedState.gameBoard[y][x] {
                    switch colorName {
                    case "cyan": self.gameBoard[y][x] = .cyan
                    case "yellow": self.gameBoard[y][x] = .yellow
                    case "purple": self.gameBoard[y][x] = .purple
                    case "blue": self.gameBoard[y][x] = .blue
                    case "orange": self.gameBoard[y][x] = .orange
                    case "green": self.gameBoard[y][x] = .green
                    case "red": self.gameBoard[y][x] = .red
                    default: self.gameBoard[y][x] = nil
                    }
                } else {
                    self.gameBoard[y][x] = nil
                }
            }
        }
        
        self.currentTetromino = savedState.currentTetromino
        self.nextTetromino = savedState.nextTetromino
        self.gameLevel = savedState.gameLevel
        self.scoreSystem = savedState.scoreSystem
        self.gameState = savedState.gameState
        
        // Update ghost piece
        updateGhostPiece()
    }
    
    // Reset the game
    func resetGame() {
        gameBoard = Array(repeating: Array(repeating: nil, count: boardWidth), count: boardHeight)
        gameState = .waiting
        gameLevel = GameLevel()
        scoreSystem.reset()
        generateNewTetromino()
        showLevelUpAnimation = false
        
        // Reset time tracking
        creationDate = Date()
        lastPlayedDate = Date()
        totalPlayTime = 0
        sessionStartTime = nil
        
        // Reset ghost piece
        updateGhostPiece()
    }
    
    // Start the game
    func startGame() {
        guard gameState != .playing else { return }
        
        withAnimation {
            gameState = .playing
        }
        sessionStartTime = Date() // Start tracking session time
        
        // Set up game loop
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.gameLoop()
            }
        
        // Auto-save the current game state when starting
        saveCurrentGameState()
    }
    
    // Pause the game
    func pauseGame() {
        if gameState == .playing {
            withAnimation {
                gameState = .paused
            }
            gameTimer?.cancel()
            
            // Update play time tracking
            if let startTime = sessionStartTime {
                totalPlayTime += Date().timeIntervalSince(startTime)
                sessionStartTime = nil
            }
            
            // Save current game state when pausing
            saveCurrentGameState()
        } else if gameState == .paused {
//            resumeGame()
        }
    }
    
    // Resume the game
    func resumeGame() {
        guard gameState == .paused else { return }
        
        
        withAnimation {
            gameState = .playing
        }
        sessionStartTime = Date() // Resume tracking session time
        lastPlayedDate = Date()
        
        // Set up game loop again
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.gameLoop()
            }
        
        // Reset the last move down time to prevent immediate movement
        lastMoveDownTime = Date()
        
        // Save current game state when resuming
        saveCurrentGameState()
    }
    
    // End the game
    func endGame() {
        withAnimation {
            gameState = .gameOver
        }
        gameTimer?.cancel()
        
        // Update play time tracking
        if let startTime = sessionStartTime {
            totalPlayTime += Date().timeIntervalSince(startTime)
            sessionStartTime = nil
        }
        
        // Save completed game to SwiftData
        saveCompletedGame()
        
        // Remove the in-progress game state since it's completed
        removeCurrentGameState()
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
                
                // Update ghost piece position when tetromino moves
                updateGhostPiece()
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
                } else {
                    // Auto-save current game state whenever a piece is placed
                    saveCurrentGameState()
                }
            }
        }
    }
    
    // Generate a new tetromino
    private func generateNewTetromino() {
        if let next = nextTetromino {
            currentTetromino = next
            nextTetromino = secondNextTetromino
        } else {
            currentTetromino = generateTetromino()
            nextTetromino = generateTetromino()
        }
        
        // Generate the next tetromino
        secondNextTetromino = generateTetromino()
        
        // Update ghost piece for the new tetromino
        updateGhostPiece()
    }
    
    private func generateTetromino() -> Tetromino {
        // Start position at the top center of the board
        let startX = (boardWidth / 2) - 1
        let type = TetrominoType.allCases.randomElement()!
        return Tetromino(type: type, startPosition: (x: startX, y: 0))
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
    
    // Added: Update ghost piece position
    func updateGhostPiece() {
        guard let current = currentTetromino, gameState == .playing else {
            ghostPiecePosition = nil
            return
        }
        
        // Create a copy of the current tetromino
        let ghostTetromino = current
        var newY = current.position.y
        
        // Find the lowest position the ghost piece can go
        while canMove(ghostTetromino, to: (ghostTetromino.position.x, newY + 1)) {
            newY += 1
        }
        
        // Set the ghost piece position
        ghostPiecePosition = (current.position.x, newY)
    }
    
    // Added: Get ghost piece absolute positions
    func ghostPieceAbsolutePositions() -> [Block] {
        guard let current = currentTetromino, let ghostPos = ghostPiecePosition else {
            return []
        }
        
        // Create a copy of the current tetromino
        var ghostTetromino = current
        ghostTetromino.position = ghostPos
        
        return ghostTetromino.absoluteBlockPositions()
    }
    
    // MARK: - User input actions
    func moveLeft() {
        guard gameState == .playing, let current = currentTetromino else { return }
        
        if canMove(current, to: (current.position.x - 1, current.position.y)) {
            currentTetromino?.position.x -= 1
            
            // Update ghost piece position
            updateGhostPiece()
        }
    }
    
    func moveRight() {
        guard gameState == .playing, let current = currentTetromino else { return }
        
        if canMove(current, to: (current.position.x + 1, current.position.y)) {
            currentTetromino?.position.x += 1
            
            // Update ghost piece position
            updateGhostPiece()
        }
    }
    
    func rotate() {
        guard gameState == .playing, let current = currentTetromino else { return }
        
        if canRotate(current) {
            currentTetromino?.rotate()
            
            // Update ghost piece position
            updateGhostPiece()
        }
    }
    
    func moveDown() {
        guard gameState == .playing, let current = currentTetromino else { return }
        
        if canMove(current, to: (current.position.x, current.position.y + 1)) {
            currentTetromino?.position.y += 1
            
            // Update ghost piece position
            updateGhostPiece()
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
    
    // MARK: - Persistence Methods
    
    // Save completed game to SwiftData
    private func saveCompletedGame() {
        guard let modelContext = modelContext, gameState == .gameOver else { return }
        
        // Calculate total play time
        let completionDate = Date()
        lastPlayedDate = completionDate
        
        // Create game session record
        let gameSession = TetrisGameSession(
            creationDate: creationDate,
            completionDate: completionDate,
            score: scoreSystem.score,
            level: gameLevel.level,
            linesCleared: gameLevel.linesCleared,
            playDuration: totalPlayTime
        )
        
        // Save to SwiftData
        modelContext.insert(gameSession)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save completed game: \(error)")
        }
    }
    
    // Save current game state for later resumption
    private func saveCurrentGameState() {
        guard gameState == .playing || gameState == .paused else { return }
        
        // Update play time if needed
        if let startTime = sessionStartTime, gameState == .paused {
            totalPlayTime += Date().timeIntervalSince(startTime)
            sessionStartTime = nil
        }
        
        // Update lastPlayedDate
        lastPlayedDate = Date()
        
        // Convert gameBoard colors to string names for serialization
        var boardColors: [[String?]] = Array(repeating: Array(repeating: nil, count: boardWidth), count: boardHeight)
        
        for y in 0..<gameBoard.count {
            for x in 0..<gameBoard[y].count {
                if let color = gameBoard[y][x] {
                    if color == .cyan { boardColors[y][x] = "cyan" }
                    else if color == .yellow { boardColors[y][x] = "yellow" }
                    else if color == .purple { boardColors[y][x] = "purple" }
                    else if color == .blue { boardColors[y][x] = "blue" }
                    else if color == .orange { boardColors[y][x] = "orange" }
                    else if color == .green { boardColors[y][x] = "green" }
                    else if color == .red { boardColors[y][x] = "red" }
                }
            }
        }
        
        // Create saved game state
        let savedState = SavedGameState(
            gameBoard: boardColors,
            currentTetromino: currentTetromino,
            nextTetromino: nextTetromino,
            gameLevel: gameLevel,
            scoreSystem: scoreSystem,
            gameState: gameState,
            creationDate: creationDate,
            lastPlayedDate: lastPlayedDate,
            totalPlayTime: totalPlayTime
        )
        
        // Convert to JSON and save to UserDefaults
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(savedState)
            UserDefaults.standard.set(data, forKey: "TetrisCurrentGame")
        } catch {
            print("Failed to save game state: \(error)")
        }
    }
    
    // Remove current game state from UserDefaults
    private func removeCurrentGameState() {
        UserDefaults.standard.removeObject(forKey: "TetrisCurrentGame")
    }
    
    // Static method to load a saved game if available
    static func loadSavedGame(modelContext: ModelContext? = nil) -> TetrisGameModel? {
        guard let data = UserDefaults.standard.data(forKey: "TetrisCurrentGame") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let savedState = try decoder.decode(SavedGameState.self, from: data)
            return TetrisGameModel(savedState: savedState, modelContext: modelContext)
        } catch {
            print("Failed to load saved game: \(error)")
            return nil
        }
    }
    
    // Get game statistics
    var gameStats: (creationDate: Date, lastPlayed: Date, playTime: TimeInterval) {
        return (creationDate, lastPlayedDate, totalPlayTime)
    }
}
