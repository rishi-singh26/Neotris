//
//  GameEngineTests.swift
//  NeotrisTests
//

import Testing
import SwiftUI
@testable import Neotris

struct GameEngineTests {

    // MARK: - Helpers

    private func makeEmptyBoard() -> [[String?]] {
        Array(repeating: Array(repeating: nil, count: 10), count: 20)
    }

    private func makeSavedState(
        board: [[String?]]? = nil,
        level: GameLevel = GameLevel(),
        score: ScoreSystem = ScoreSystem(),
        currentTetromino: Tetromino? = nil,
        nextTetromino: Tetromino? = nil
    ) -> SavedGameState {
        SavedGameState(
            gameBoard: board ?? makeEmptyBoard(),
            currentTetromino: currentTetromino,
            nextTetromino: nextTetromino,
            gameLevel: level,
            scoreSystem: score,
            gameState: .paused,
            creationDate: Date(),
            lastPlayedDate: Date(),
            totalPlayTime: 0
        )
    }

    // MARK: - Initialization

    @Test func boardHasCorrectDimensions() {
        let engine = GameEngine()
        #expect(engine.boardWidth == 10)
        #expect(engine.boardHeight == 20)
        #expect(engine.gameBoard.count == 20)
        #expect(engine.gameBoard[0].count == 10)
    }

    @Test func boardIsEmptyAfterInit() {
        let engine = GameEngine()
        let allNil = engine.gameBoard.allSatisfy { $0.allSatisfy { $0 == nil } }
        #expect(allNil)
    }

    @Test func allThreeTetrominosGeneratedOnInit() {
        let engine = GameEngine()
        #expect(engine.currentTetromino != nil)
        #expect(engine.nextTetromino != nil)
        #expect(engine.secondNextTetromino != nil)
    }

    @Test func ghostPieceSetOnInit() {
        let engine = GameEngine()
        #expect(engine.ghostPiecePosition != nil)
    }

    @Test func initialLevelIsOne() {
        let engine = GameEngine()
        #expect(engine.gameLevel.level == 1)
    }

    @Test func initialScoreIsZero() {
        let engine = GameEngine()
        #expect(engine.scoreSystem.score == 0)
    }

    // MARK: - Move Left

    @Test func moveLeftSucceedsFromSpawnPosition() {
        let engine = GameEngine()
        #expect(engine.moveLeft() == true)
    }

    @Test func moveLeftUpdatesPositionX() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 5))
        engine.moveLeft()
        #expect(engine.currentTetromino?.position.x == 3)
    }

    @Test func moveLeftFailsWhenIPieceAtLeftEdge() {
        let engine = GameEngine()
        // I piece at x=0: leftmost absolute block is at x=0. Moving left → x=-1 → out of bounds.
        engine.currentTetromino = Tetromino(type: .i, startPosition: (x: 0, y: 5))
        #expect(engine.moveLeft() == false)
    }

    @Test func moveLeftDoesNotMoveWhenBlocked() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .i, startPosition: (x: 4, y: 5))
        // Block at (3,5) — directly left of I piece
        engine.gameBoard[5][3] = .z
        let result = engine.moveLeft()
        #expect(result == false)
        #expect(engine.currentTetromino?.position.x == 4)
    }

    @Test func consecutiveMoveLeftEventuallyHitsWall() {
        let engine = GameEngine()
        for _ in 0..<15 {
            engine.moveLeft()
        }
        #expect(engine.moveLeft() == false)
    }

    // MARK: - Move Right

    @Test func moveRightSucceedsFromSpawnPosition() {
        let engine = GameEngine()
        #expect(engine.moveRight() == true)
    }

    @Test func moveRightUpdatesPositionX() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 5))
        engine.moveRight()
        #expect(engine.currentTetromino?.position.x == 5)
    }

    @Test func moveRightFailsWhenIPieceAtRightEdge() {
        let engine = GameEngine()
        // I piece at x=6: absolute blocks at (6,y),(7,y),(8,y),(9,y). Moving right → (10,y) → out of bounds.
        engine.currentTetromino = Tetromino(type: .i, startPosition: (x: 6, y: 5))
        #expect(engine.moveRight() == false)
    }

    @Test func moveRightFailsWhenBlockedByPlacedBlock() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .i, startPosition: (x: 2, y: 5))
        // I piece occupies (2,5)..(5,5). Place block at (6,5).
        engine.gameBoard[5][6] = .z
        #expect(engine.moveRight() == false)
    }

    @Test func consecutiveMoveRightEventuallyHitsWall() {
        let engine = GameEngine()
        for _ in 0..<15 {
            engine.moveRight()
        }
        #expect(engine.moveRight() == false)
    }

    // MARK: - Move Down

    @Test func moveDownSucceedsWhenSpaceAvailable() {
        let engine = GameEngine()
        #expect(engine.moveDown() == true)
    }

    @Test func moveDownUpdatesPositionY() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 5))
        engine.moveDown()
        #expect(engine.currentTetromino?.position.y == 6)
    }

    @Test func moveDownFailsWhenOPieceAtBottom() {
        let engine = GameEngine()
        // O piece is 2 blocks tall. At y=18 it occupies rows 18 and 19 (bottom).
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 18))
        #expect(engine.moveDown() == false)
    }

    @Test func moveDownFailsWhenBlockedByPlacedBlock() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 5))
        // O piece: (4,5),(5,5),(4,6),(5,6). Block directly below at (4,7) and (5,7).
        engine.gameBoard[7][4] = .z
        engine.gameBoard[7][5] = .z
        #expect(engine.moveDown() == false)
    }

    @Test func consecutiveMoveDownEventuallyHitsBottom() {
        let engine = GameEngine()
        for _ in 0..<25 {
            engine.moveDown()
        }
        #expect(engine.moveDown() == false)
    }

    // MARK: - Rotate

    @Test func rotateSucceedsInOpenSpace() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .t, startPosition: (x: 4, y: 5))
        #expect(engine.rotate() == true)
    }

    @Test func rotateChangesBlocks() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .t, startPosition: (x: 4, y: 5))
        let before = engine.currentTetromino!.blocks
        engine.rotate()
        #expect(engine.currentTetromino!.blocks != before)
    }

    @Test func rotateDoesNotChangePosition() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .t, startPosition: (x: 4, y: 5))
        engine.rotate()
        #expect(engine.currentTetromino?.position.x == 4)
        #expect(engine.currentTetromino?.position.y == 5)
    }

    @Test func rotateFailsWhenRotatedBlockOutOfBounds() {
        let engine = GameEngine()
        // I piece at y=1: CW rotation puts one block at y=-1 (out of bounds).
        engine.currentTetromino = Tetromino(type: .i, startPosition: (x: 4, y: 1))
        #expect(engine.rotate() == false)
    }

    @Test func rotateFailsWhenBlockedByPlacedBlock() {
        let engine = GameEngine()
        // T piece at (4,5). After CW rotation: block at absolute (5,4).
        engine.currentTetromino = Tetromino(type: .t, startPosition: (x: 4, y: 5))
        engine.gameBoard[4][5] = .z
        #expect(engine.rotate() == false)
    }

    @Test func rotateReturnsTrueForOPieceButBlocksUnchanged() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 5))
        let before = engine.currentTetromino!.blocks
        // O piece rotate() is a no-op; canRotate still returns true since blocks don't change
        let result = engine.rotate()
        #expect(result == true)
        #expect(engine.currentTetromino!.blocks == before)
    }

    // MARK: - Hard Drop

    @Test func hardDropSendsPieceToBottom() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 0))
        engine.hardDrop()
        // O is 2 blocks tall; bottom row is 19, so piece lands at y=18.
        #expect(engine.currentTetromino?.position.y == 18)
    }

    @Test func hardDropStopsAbovePlacedBlocks() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 0))
        // Block the O piece at y=15 (occupies (4,15),(5,15))
        engine.gameBoard[15][4] = .z
        engine.gameBoard[15][5] = .z
        engine.hardDrop()
        // O piece lands at y=13 (occupies rows 13,14; row 15 is blocked)
        #expect(engine.currentTetromino?.position.y == 13)
    }

    @Test func hardDropOnGroundedPieceDoesNotMove() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 18))
        engine.hardDrop()
        #expect(engine.currentTetromino?.position.y == 18)
    }

    @Test func hardDropIPieceToBottom() {
        let engine = GameEngine()
        // I piece is 1 block tall, so it lands at row 19.
        engine.currentTetromino = Tetromino(type: .i, startPosition: (x: 0, y: 0))
        engine.hardDrop()
        #expect(engine.currentTetromino?.position.y == 19)
    }

    // MARK: - Ghost Piece

    @Test func ghostPieceNonNilWhenPieceExists() {
        let engine = GameEngine()
        #expect(engine.ghostPiecePosition != nil)
    }

    @Test func ghostPieceXMatchesCurrentPieceX() {
        let engine = GameEngine()
        let pieceX = engine.currentTetromino?.position.x
        #expect(engine.ghostPiecePosition?.x == pieceX)
    }

    @Test func ghostPieceYAtOrBelowCurrentPiece() {
        let engine = GameEngine()
        let pieceY = engine.currentTetromino?.position.y ?? 0
        let ghostY = engine.ghostPiecePosition?.y ?? 0
        #expect(ghostY >= pieceY)
    }

    @Test func ghostPieceXUpdatesAfterMoveLeft() {
        let engine = GameEngine()
        let originalGhostX = engine.ghostPiecePosition?.x ?? 0
        engine.moveLeft()
        #expect(engine.ghostPiecePosition?.x == originalGhostX - 1)
    }

    @Test func ghostPieceXUpdatesAfterMoveRight() {
        let engine = GameEngine()
        let originalGhostX = engine.ghostPiecePosition?.x ?? 0
        engine.moveRight()
        #expect(engine.ghostPiecePosition?.x == originalGhostX + 1)
    }

    @Test func ghostPieceAbsolutePositionsFourBlocks() {
        let engine = GameEngine()
        #expect(engine.ghostPieceAbsolutePositions().count == 4)
    }

    @Test func ghostPieceAbsolutePositionsEmptyWithoutPiece() {
        let engine = GameEngine()
        engine.currentTetromino = nil
        engine.hardDrop() // no-op
        let positions = engine.ghostPieceAbsolutePositions()
        #expect(positions.isEmpty)
    }

    // MARK: - Tick

    @Test func tickReturnsNoOpWhenTimeNotElapsed() {
        let engine = GameEngine()
        engine.lastMoveDownTime = Date()
        let result = engine.tick()
        #expect(result.linesCleared == 0)
        #expect(result.didLevelUp == false)
        #expect(result.isGameOver == false)
        #expect(result.piecePlaced == false)
    }

    @Test func tickMovesPieceDownWhenTimeElapsed() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 5))
        engine.lastMoveDownTime = .distantPast
        _ = engine.tick()
        #expect(engine.currentTetromino?.position.y == 6)
    }

    @Test func tickPlacesPieceWhenAtBottom() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 18))
        engine.lastMoveDownTime = .distantPast
        let result = engine.tick()
        #expect(result.piecePlaced == true)
    }

    @Test func tickPaintsBoardAfterPlacing() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 18))
        engine.lastMoveDownTime = .distantPast
        _ = engine.tick()
        // O piece placed at (4,18): board cells should store .o (O-piece type)
        #expect(engine.gameBoard[18][4] == .o)
        #expect(engine.gameBoard[18][5] == .o)
        #expect(engine.gameBoard[19][4] == .o)
        #expect(engine.gameBoard[19][5] == .o)
    }

    @Test func tickClearsOneCompletedLine() {
        let engine = GameEngine()
        // I piece at (0,18): absolute blocks (0,18),(1,18),(2,18),(3,18)
        engine.currentTetromino = Tetromino(type: .i, startPosition: (x: 0, y: 18))
        // Fill rest of row 18: (4..9)
        for x in 4..<10 { engine.gameBoard[18][x] = .z }
        // Block downward movement: fill (0..3) of row 19
        for x in 0..<4 { engine.gameBoard[19][x] = .z }
        engine.lastMoveDownTime = .distantPast

        let result = engine.tick()

        #expect(result.linesCleared == 1)
        #expect(result.piecePlaced == true)
        #expect(engine.scoreSystem.score > 0)
    }

    @Test func tickScoreIncreasesAfterLineClear() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .i, startPosition: (x: 0, y: 18))
        for x in 4..<10 { engine.gameBoard[18][x] = .z }
        for x in 0..<4 { engine.gameBoard[19][x] = .z }
        engine.lastMoveDownTime = .distantPast

        _ = engine.tick()

        // 1 line at level 1 = 40 points
        #expect(engine.scoreSystem.score == 40)
    }

    @Test func tickRowShiftsDownAfterLineClear() {
        let engine = GameEngine()
        // Place a marker block in row 17 (above the line to be cleared)
        engine.gameBoard[17][9] = .t
        engine.currentTetromino = Tetromino(type: .i, startPosition: (x: 0, y: 18))
        for x in 4..<10 { engine.gameBoard[18][x] = .z }
        for x in 0..<4 { engine.gameBoard[19][x] = .z }
        engine.lastMoveDownTime = .distantPast

        _ = engine.tick()

        // Row 17 should have shifted down to row 18
        #expect(engine.gameBoard[18][9] == .t)
    }

    @Test func tickDetectsGameOver() {
        let engine = GameEngine()
        // Partially fill row 0 — enough to trigger isGameOver() but NOT a complete line,
        // so checkForCompletedLines() won't clear it before isGameOver() is evaluated.
        engine.gameBoard[0][0] = .z
        engine.gameBoard[0][1] = .z
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 18))
        engine.lastMoveDownTime = .distantPast

        let result = engine.tick()

        #expect(result.piecePlaced == true)
        #expect(result.isGameOver == true)
    }

    @Test func tickDoesNotReportGameOverOnNormalMove() {
        let engine = GameEngine()
        engine.currentTetromino = Tetromino(type: .o, startPosition: (x: 4, y: 5))
        engine.lastMoveDownTime = .distantPast

        let result = engine.tick()

        // Piece moves down — not placed, not game over
        #expect(result.isGameOver == false)
        #expect(result.piecePlaced == false)
    }

    // MARK: - Reset

    @Test func resetClearsAllBoardCells() {
        let engine = GameEngine()
        engine.gameBoard[10][5] = .z
        engine.gameBoard[19][9] = .i
        engine.reset()
        let allNil = engine.gameBoard.allSatisfy { $0.allSatisfy { $0 == nil } }
        #expect(allNil)
    }

    @Test func resetGeneratesNewPiece() {
        let engine = GameEngine()
        engine.reset()
        #expect(engine.currentTetromino != nil)
        #expect(engine.nextTetromino != nil)
    }

    @Test func resetResetsScore() {
        let engine = GameEngine()
        engine.scoreSystem.addScore(for: 4, level: 1)
        engine.reset()
        #expect(engine.scoreSystem.score == 0)
    }

    @Test func resetResetsLevel() {
        let engine = GameEngine()
        _ = engine.gameLevel.addLines(10)
        engine.reset()
        #expect(engine.gameLevel.level == 1)
        #expect(engine.gameLevel.linesCleared == 0)
    }

    @Test func resetPreservesBoardDimensions() {
        let engine = GameEngine()
        engine.reset()
        #expect(engine.gameBoard.count == 20)
        #expect(engine.gameBoard[0].count == 10)
    }

    // MARK: - Init from SavedGameState

    @Test func initFromSavedStateRestoresBoardTypes() {
        var board = makeEmptyBoard()
        board[19] = Array(repeating: "z", count: 10)   // Z-piece raw value
        board[18][0] = "i"                               // I-piece raw value

        let savedState = makeSavedState(board: board)
        let engine = GameEngine(savedState: savedState)

        #expect(engine.gameBoard[19].allSatisfy { $0 == .z })
        #expect(engine.gameBoard[18][0] == .i)
    }

    @Test func initFromSavedStateRestoresNilCells() {
        let board = makeEmptyBoard()
        let savedState = makeSavedState(board: board)
        let engine = GameEngine(savedState: savedState)
        #expect(engine.gameBoard[0][0] == nil)
        #expect(engine.gameBoard[10][5] == nil)
    }

    @Test func initFromSavedStateRestoresLevel() {
        var level = GameLevel()
        _ = level.addLines(10) // level = 3

        let savedState = makeSavedState(level: level)
        let engine = GameEngine(savedState: savedState)

        #expect(engine.gameLevel.level == 3)
        #expect(engine.gameLevel.linesCleared == 10)
    }

    @Test func initFromSavedStateRestoresScore() {
        var score = ScoreSystem()
        score.addScore(for: 4, level: 1) // 1200

        let savedState = makeSavedState(score: score)
        let engine = GameEngine(savedState: savedState)

        #expect(engine.scoreSystem.score == score.score)
    }

    @Test func initFromSavedStateGeneratesSecondNextTetromino() {
        let savedState = makeSavedState()
        let engine = GameEngine(savedState: savedState)
        #expect(engine.secondNextTetromino != nil)
    }

    @Test func allTypeRawValuesRestoredCorrectly() {
        // Tests new format: TetrominoType.rawValue strings
        let typeMap: [(String, TetrominoType)] = [
            ("i", .i), ("o", .o), ("t", .t), ("j", .j), ("l", .l), ("s", .s), ("z", .z)
        ]

        for (rawValue, expectedType) in typeMap {
            var board = makeEmptyBoard()
            board[0][0] = rawValue

            let savedState = makeSavedState(board: board)
            let engine = GameEngine(savedState: savedState)

            #expect(engine.gameBoard[0][0] == expectedType, "Type '\(rawValue)' not restored correctly")
        }
    }

    @Test func oldColorNameFormatRestoredCorrectly() {
        // Tests backward compatibility: old saves used color names
        let colorNameMap: [(String, TetrominoType)] = [
            ("cyan", .i), ("yellow", .o), ("purple", .t),
            ("blue", .j), ("orange", .l), ("green", .s), ("red", .z)
        ]

        for (colorName, expectedType) in colorNameMap {
            var board = makeEmptyBoard()
            board[0][0] = colorName

            let savedState = makeSavedState(board: board)
            let engine = GameEngine(savedState: savedState)

            #expect(engine.gameBoard[0][0] == expectedType, "Old color name '\(colorName)' not mapped to correct type")
        }
    }

    @Test func unknownColorNameRestoredAsNil() {
        var board = makeEmptyBoard()
        board[5][5] = "unknownColor"

        let savedState = makeSavedState(board: board)
        let engine = GameEngine(savedState: savedState)

        #expect(engine.gameBoard[5][5] == nil)
    }
}
