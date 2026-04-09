//
//  GameEngine.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import SwiftUI
import Observation

// MARK: - GameTickResult

struct GameTickResult {
    let linesCleared: Int
    let didLevelUp: Bool
    let isGameOver: Bool
    let piecePlaced: Bool

    static let noOp = GameTickResult(linesCleared: 0, didLevelUp: false, isGameOver: false, piecePlaced: false)
}

// MARK: - GameEngine

@Observable
final class GameEngine {
    // MARK: - Constants
    let boardWidth = 10
    let boardHeight = 20

    // MARK: - Observable State
    var gameBoard: [[Color?]]
    var currentTetromino: Tetromino?
    var nextTetromino: Tetromino?
    var secondNextTetromino: Tetromino?
    var gameLevel: GameLevel
    var scoreSystem: ScoreSystem
    var ghostPiecePosition: (x: Int, y: Int)?

    // MARK: - Internal timing (not observed — changes every frame)
    @ObservationIgnored var lastMoveDownTime: Date = Date()

    // MARK: - Init

    init() {
        self.gameBoard = Array(repeating: Array(repeating: nil, count: 10), count: 20)
        self.gameLevel = GameLevel()
        self.scoreSystem = ScoreSystem()
        self.currentTetromino = nil
        self.nextTetromino = nil
        self.secondNextTetromino = nil
        self.ghostPiecePosition = nil
        generateNewTetromino()
    }

    init(savedState: SavedGameState) {
        let width = savedState.gameBoard[0].count
        let height = savedState.gameBoard.count
        self.gameBoard = Array(repeating: Array(repeating: nil, count: width), count: height)
        self.gameLevel = savedState.gameLevel
        self.scoreSystem = savedState.scoreSystem
        self.currentTetromino = savedState.currentTetromino
        self.nextTetromino = savedState.nextTetromino
        self.secondNextTetromino = nil
        self.ghostPiecePosition = nil

        for y in 0..<height {
            for x in 0..<width {
                self.gameBoard[y][x] = color(from: savedState.gameBoard[y][x])
            }
        }

        // secondNextTetromino is not persisted — generate fresh
        self.secondNextTetromino = generateTetromino()
        updateGhostPiece()
    }

    // MARK: - Public Interface

    func reset() {
        gameBoard = Array(repeating: Array(repeating: nil, count: boardWidth), count: boardHeight)
        gameLevel = GameLevel()
        scoreSystem = ScoreSystem()
        currentTetromino = nil
        nextTetromino = nil
        secondNextTetromino = nil
        ghostPiecePosition = nil
        lastMoveDownTime = Date()
        generateNewTetromino()
    }

    /// Called by the game loop timer at 60 fps.
    /// Handles gravity: moves piece down when drop speed elapsed, or places it if blocked.
    func tick() -> GameTickResult {
        guard currentTetromino != nil else { return .noOp }
        guard Date().timeIntervalSince(lastMoveDownTime) >= gameLevel.dropSpeed else { return .noOp }

        lastMoveDownTime = Date()

        guard let current = currentTetromino else { return .noOp }

        if canMove(current, to: (current.position.x, current.position.y + 1)) {
            currentTetromino?.position.y += 1
            updateGhostPiece()
            return .noOp
        } else {
            placeTetromino()
            let (linesCleared, didLevelUp) = checkForCompletedLines()
            generateNewTetromino()
            let gameOver = isGameOver()
            return GameTickResult(
                linesCleared: linesCleared,
                didLevelUp: didLevelUp,
                isGameOver: gameOver,
                piecePlaced: true
            )
        }
    }

    @discardableResult
    func moveLeft() -> Bool {
        guard let current = currentTetromino,
              canMove(current, to: (current.position.x - 1, current.position.y)) else { return false }
        currentTetromino?.position.x -= 1
        updateGhostPiece()
        return true
    }

    @discardableResult
    func moveRight() -> Bool {
        guard let current = currentTetromino,
              canMove(current, to: (current.position.x + 1, current.position.y)) else { return false }
        currentTetromino?.position.x += 1
        updateGhostPiece()
        return true
    }

    @discardableResult
    func moveDown() -> Bool {
        guard let current = currentTetromino,
              canMove(current, to: (current.position.x, current.position.y + 1)) else { return false }
        currentTetromino?.position.y += 1
        updateGhostPiece()
        return true
    }

    @discardableResult
    func rotate() -> Bool {
        guard let current = currentTetromino, canRotate(current) else { return false }
        currentTetromino?.rotate()
        updateGhostPiece()
        return true
    }

    func hardDrop() {
        guard let current = currentTetromino else { return }
        var newY = current.position.y
        while canMove(current, to: (current.position.x, newY + 1)) {
            newY += 1
        }
        if newY != current.position.y {
            currentTetromino?.position.y = newY
            updateGhostPiece()
            // Reset timer so the piece isn't placed immediately on the next tick
            lastMoveDownTime = Date()
        }
    }

    func ghostPieceAbsolutePositions() -> [Block] {
        guard let current = currentTetromino, let ghostPos = ghostPiecePosition else { return [] }
        var ghost = current
        ghost.position = ghostPos
        return ghost.absoluteBlockPositions()
    }

    // MARK: - Private Game Logic

    private func canMove(_ tetromino: Tetromino, to newPosition: (x: Int, y: Int)) -> Bool {
        var moved = tetromino
        moved.position = newPosition
        for block in moved.absoluteBlockPositions() {
            if block.x < 0 || block.x >= boardWidth || block.y < 0 || block.y >= boardHeight {
                return false
            }
            if gameBoard[block.y][block.x] != nil {
                return false
            }
        }
        return true
    }

    private func canRotate(_ tetromino: Tetromino) -> Bool {
        var rotated = tetromino
        rotated.rotate()
        return canMove(rotated, to: tetromino.position)
    }

    private func placeTetromino() {
        guard let current = currentTetromino else { return }
        for block in current.absoluteBlockPositions() {
            if block.y >= 0 && block.y < boardHeight && block.x >= 0 && block.x < boardWidth {
                gameBoard[block.y][block.x] = current.type.color
            }
        }
    }

    private func checkForCompletedLines() -> (linesCleared: Int, didLevelUp: Bool) {
        var completed = 0
        for y in (0..<boardHeight).reversed() {
            if gameBoard[y].allSatisfy({ $0 != nil }) {
                for j in stride(from: y, through: 1, by: -1) {
                    gameBoard[j] = gameBoard[j - 1]
                }
                gameBoard[0] = Array(repeating: nil, count: boardWidth)
                completed += 1
            }
        }
        guard completed > 0 else { return (0, false) }
        scoreSystem.addScore(for: completed, level: gameLevel.level)
        let didLevelUp = gameLevel.addLines(completed)
        return (completed, didLevelUp)
    }

    private func generateNewTetromino() {
        if let next = nextTetromino {
            currentTetromino = next
            nextTetromino = secondNextTetromino
        } else {
            currentTetromino = generateTetromino()
            nextTetromino = generateTetromino()
        }
        secondNextTetromino = generateTetromino()
        updateGhostPiece()
    }

    private func generateTetromino() -> Tetromino {
        let startX = (boardWidth / 2) - 1
        let type = TetrominoType.allCases.randomElement()!
        return Tetromino(type: type, startPosition: (x: startX, y: 0))
    }

    private func updateGhostPiece() {
        guard let current = currentTetromino else {
            ghostPiecePosition = nil
            return
        }
        var newY = current.position.y
        while canMove(current, to: (current.position.x, newY + 1)) {
            newY += 1
        }
        ghostPiecePosition = (current.position.x, newY)
    }

    private func isGameOver() -> Bool {
        gameBoard[0].contains(where: { $0 != nil })
    }

    // MARK: - Color helpers (for save/restore)

    private func color(from name: String?) -> Color? {
        switch name {
        case "cyan":   return .cyan
        case "yellow": return .yellow
        case "purple": return .purple
        case "blue":   return .blue
        case "orange": return .orange
        case "green":  return .green
        case "red":    return .red
        default:       return nil
        }
    }
}
