//
//  UserDefaultsTests.swift
//  NeotrisTests
//
//  Consolidates ScoreSystemTests, PersistenceServiceTests, and GameViewModelTests
//  into a single @Suite(.serialized) wrapper to prevent UserDefaults race conditions
//  when running the full test suite (Swift Testing runs different suites concurrently).
//

import Testing
import SwiftUI
import SwiftData
@testable import Neotris

// MARK: - Parent suite — serializes all three child suites relative to each other

@Suite(.serialized)
struct UserDefaultsTests {

    // MARK: - ScoreSystem

    @Suite(.serialized)
    struct ScoreSystemTests {

        init() {
            UserDefaults.standard.removeObject(forKey: ScoreSystem.highScoreKey)
        }

        // MARK: Initial state

        @Test func initialScoreIsZero() {
            let system = ScoreSystem()
            #expect(system.score == 0)
        }

        @Test func initialHighScoreIsZeroWhenNoDefaults() {
            let system = ScoreSystem()
            #expect(system.highScore == 0)
        }

        // MARK: Scoring — line counts at level 1

        @Test func scoreOneLine() {
            var system = ScoreSystem()
            system.addScore(for: 1, level: 1)
            #expect(system.score == 40)
        }

        @Test func scoreTwoLines() {
            var system = ScoreSystem()
            system.addScore(for: 2, level: 1)
            #expect(system.score == 100)
        }

        @Test func scoreThreeLines() {
            var system = ScoreSystem()
            system.addScore(for: 3, level: 1)
            #expect(system.score == 300)
        }

        @Test func scoreFourLines() {
            var system = ScoreSystem()
            system.addScore(for: 4, level: 1)
            #expect(system.score == 1200)
        }

        @Test func scoreZeroLinesIsZero() {
            var system = ScoreSystem()
            system.addScore(for: 0, level: 1)
            #expect(system.score == 0)
        }

        @Test func scoreFiveLinesIsZero() {
            var system = ScoreSystem()
            system.addScore(for: 5, level: 1)
            #expect(system.score == 0)
        }

        // MARK: Level multiplier

        @Test func levelMultiplierAtLevel2() {
            var system = ScoreSystem()
            system.addScore(for: 1, level: 2)
            #expect(system.score == 80)
        }

        @Test func levelMultiplierAtLevel3() {
            var system = ScoreSystem()
            system.addScore(for: 1, level: 3)
            #expect(system.score == 120)
        }

        @Test func fourLinesAtLevel3() {
            var system = ScoreSystem()
            system.addScore(for: 4, level: 3)
            #expect(system.score == 3600)
        }

        // MARK: Score accumulation

        @Test func scoreAccumulatesAcrossMultipleCalls() {
            var system = ScoreSystem()
            system.addScore(for: 1, level: 1)
            system.addScore(for: 2, level: 1)
            #expect(system.score == 140)
        }

        // MARK: High score

        @Test func highScoreUpdatesWhenScoreExceedsIt() {
            var system = ScoreSystem()
            system.addScore(for: 4, level: 1)
            #expect(system.highScore == 1200)
        }

        @Test func highScoreDoesNotDropWhenScoreIsLower() {
            var system = ScoreSystem()
            system.addScore(for: 4, level: 1) // score = 1200, highScore = 1200
            system.reset()                    // score = 0, highScore remains 1200
            system.addScore(for: 1, level: 1) // score = 40, highScore stays 1200
            #expect(system.highScore == 1200)
        }

        @Test func highScoreWrittenToUserDefaults() {
            var system = ScoreSystem()
            system.addScore(for: 4, level: 1) // highScore = 1200
            let stored = UserDefaults.standard.integer(forKey: ScoreSystem.highScoreKey)
            #expect(stored == 1200)
        }

        @Test func highScoreLoadedFromUserDefaultsOnInit() {
            UserDefaults.standard.set(9999, forKey: ScoreSystem.highScoreKey)
            let system = ScoreSystem()
            #expect(system.highScore == 9999)
        }

        // MARK: Reset

        @Test func resetZeroesScore() {
            var system = ScoreSystem()
            system.addScore(for: 2, level: 1)
            system.reset()
            #expect(system.score == 0)
        }

        @Test func resetPreservesHighScore() {
            var system = ScoreSystem()
            system.addScore(for: 4, level: 1) // highScore = 1200
            system.reset()
            #expect(system.highScore == 1200)
        }

        @Test func resetDoesNotClearUserDefaultsHighScore() {
            var system = ScoreSystem()
            system.addScore(for: 4, level: 1) // stores 1200 in UserDefaults
            system.reset()
            let stored = UserDefaults.standard.integer(forKey: ScoreSystem.highScoreKey)
            #expect(stored == 1200)
        }

        // MARK: Codable

        @Test func codableRoundTrip() throws {
            var system = ScoreSystem()
            system.addScore(for: 3, level: 2)
            let data = try JSONEncoder().encode(system)
            let decoded = try JSONDecoder().decode(ScoreSystem.self, from: data)
            #expect(decoded.score == system.score)
            #expect(decoded.highScore == system.highScore)
        }
    }

    // MARK: - PersistenceService

    @Suite(.serialized)
    struct PersistenceServiceTests {

        init() {
            UserDefaults.standard.removeObject(forKey: "TetrisCurrentGame")
        }

        private func makeService() -> PersistenceService {
            PersistenceService()
        }

        // MARK: Save / Load round-trip

        @Test func loadReturnsNilBeforeSave() {
            let service = makeService()
            #expect(service.load() == nil)
        }

        @Test func saveAndLoadReturnsNonNil() {
            let service = makeService()
            service.save(
                gameBoard: Array(repeating: Array(repeating: nil, count: 10), count: 20),
                currentTetromino: nil,
                nextTetromino: nil,
                gameLevel: GameLevel(),
                scoreSystem: ScoreSystem(),
                gameState: .paused,
                creationDate: Date(),
                lastPlayedDate: Date(),
                totalPlayTime: 0
            )
            #expect(service.load() != nil)
        }

        @Test func clearThenLoadReturnsNil() {
            let service = makeService()
            service.save(
                gameBoard: Array(repeating: Array(repeating: nil, count: 10), count: 20),
                currentTetromino: nil,
                nextTetromino: nil,
                gameLevel: GameLevel(),
                scoreSystem: ScoreSystem(),
                gameState: .paused,
                creationDate: Date(),
                lastPlayedDate: Date(),
                totalPlayTime: 0
            )
            service.clear()
            #expect(service.load() == nil)
        }

        // MARK: Field preservation

        @Test func savedGameStatePreservesLevel() throws {
            let service = makeService()
            var level = GameLevel()
            _ = level.addLines(10)
            service.save(
                gameBoard: Array(repeating: Array(repeating: nil, count: 10), count: 20),
                currentTetromino: nil,
                nextTetromino: nil,
                gameLevel: level,
                scoreSystem: ScoreSystem(),
                gameState: .paused,
                creationDate: Date(),
                lastPlayedDate: Date(),
                totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameLevel.level == level.level)
            #expect(loaded.gameLevel.linesCleared == level.linesCleared)
        }

        @Test func savedGameStatePreservesScore() throws {
            let service = makeService()
            var scoreSystem = ScoreSystem()
            scoreSystem.addScore(for: 2, level: 1)
            service.save(
                gameBoard: Array(repeating: Array(repeating: nil, count: 10), count: 20),
                currentTetromino: nil,
                nextTetromino: nil,
                gameLevel: GameLevel(),
                scoreSystem: scoreSystem,
                gameState: .paused,
                creationDate: Date(),
                lastPlayedDate: Date(),
                totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.scoreSystem.score == scoreSystem.score)
        }

        @Test func savedGameStatePreservesGameState() throws {
            let service = makeService()
            service.save(
                gameBoard: Array(repeating: Array(repeating: nil, count: 10), count: 20),
                currentTetromino: nil,
                nextTetromino: nil,
                gameLevel: GameLevel(),
                scoreSystem: ScoreSystem(),
                gameState: .paused,
                creationDate: Date(),
                lastPlayedDate: Date(),
                totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameState == .paused)
        }

        @Test func savedGameStatePreservesTotalPlayTime() throws {
            let service = makeService()
            let playTime: TimeInterval = 123.45
            service.save(
                gameBoard: Array(repeating: Array(repeating: nil, count: 10), count: 20),
                currentTetromino: nil,
                nextTetromino: nil,
                gameLevel: GameLevel(),
                scoreSystem: ScoreSystem(),
                gameState: .paused,
                creationDate: Date(),
                lastPlayedDate: Date(),
                totalPlayTime: playTime
            )
            let loaded = try #require(service.load())
            #expect(abs(loaded.totalPlayTime - playTime) < 0.001)
        }

        @Test func savedGameStatePreservesTetrominoType() throws {
            let service = makeService()
            let tetromino = Tetromino(type: .z, startPosition: (x: 4, y: 0))
            service.save(
                gameBoard: Array(repeating: Array(repeating: nil, count: 10), count: 20),
                currentTetromino: tetromino,
                nextTetromino: nil,
                gameLevel: GameLevel(),
                scoreSystem: ScoreSystem(),
                gameState: .playing,
                creationDate: Date(),
                lastPlayedDate: Date(),
                totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.currentTetromino?.type == .z)
        }

        // MARK: Color serialization

        @Test func colorCyanSerializedAndRestored() throws {
            let service = makeService()
            var board = Array(repeating: Array(repeating: Optional<Color>.none, count: 10), count: 20)
            board[0][0] = .cyan
            service.save(
                gameBoard: board,
                currentTetromino: nil,
                nextTetromino: nil,
                gameLevel: GameLevel(),
                scoreSystem: ScoreSystem(),
                gameState: .paused,
                creationDate: Date(),
                lastPlayedDate: Date(),
                totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameBoard[0][0] == "cyan")
        }

        @Test func colorYellowSerializedAndRestored() throws {
            let service = makeService()
            var board = Array(repeating: Array(repeating: Optional<Color>.none, count: 10), count: 20)
            board[0][0] = .yellow
            service.save(
                gameBoard: board, currentTetromino: nil, nextTetromino: nil,
                gameLevel: GameLevel(), scoreSystem: ScoreSystem(), gameState: .paused,
                creationDate: Date(), lastPlayedDate: Date(), totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameBoard[0][0] == "yellow")
        }

        @Test func colorPurpleSerializedAndRestored() throws {
            let service = makeService()
            var board = Array(repeating: Array(repeating: Optional<Color>.none, count: 10), count: 20)
            board[0][0] = .purple
            service.save(
                gameBoard: board, currentTetromino: nil, nextTetromino: nil,
                gameLevel: GameLevel(), scoreSystem: ScoreSystem(), gameState: .paused,
                creationDate: Date(), lastPlayedDate: Date(), totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameBoard[0][0] == "purple")
        }

        @Test func colorBlueSerializedAndRestored() throws {
            let service = makeService()
            var board = Array(repeating: Array(repeating: Optional<Color>.none, count: 10), count: 20)
            board[0][0] = .blue
            service.save(
                gameBoard: board, currentTetromino: nil, nextTetromino: nil,
                gameLevel: GameLevel(), scoreSystem: ScoreSystem(), gameState: .paused,
                creationDate: Date(), lastPlayedDate: Date(), totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameBoard[0][0] == "blue")
        }

        @Test func colorOrangeSerializedAndRestored() throws {
            let service = makeService()
            var board = Array(repeating: Array(repeating: Optional<Color>.none, count: 10), count: 20)
            board[0][0] = .orange
            service.save(
                gameBoard: board, currentTetromino: nil, nextTetromino: nil,
                gameLevel: GameLevel(), scoreSystem: ScoreSystem(), gameState: .paused,
                creationDate: Date(), lastPlayedDate: Date(), totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameBoard[0][0] == "orange")
        }

        @Test func colorGreenSerializedAndRestored() throws {
            let service = makeService()
            var board = Array(repeating: Array(repeating: Optional<Color>.none, count: 10), count: 20)
            board[0][0] = .green
            service.save(
                gameBoard: board, currentTetromino: nil, nextTetromino: nil,
                gameLevel: GameLevel(), scoreSystem: ScoreSystem(), gameState: .paused,
                creationDate: Date(), lastPlayedDate: Date(), totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameBoard[0][0] == "green")
        }

        @Test func colorRedSerializedAndRestored() throws {
            let service = makeService()
            var board = Array(repeating: Array(repeating: Optional<Color>.none, count: 10), count: 20)
            board[0][0] = .red
            service.save(
                gameBoard: board, currentTetromino: nil, nextTetromino: nil,
                gameLevel: GameLevel(), scoreSystem: ScoreSystem(), gameState: .paused,
                creationDate: Date(), lastPlayedDate: Date(), totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameBoard[0][0] == "red")
        }

        @Test func nilColorSerializedAsNil() throws {
            let service = makeService()
            let board = Array(repeating: Array(repeating: Optional<Color>.none, count: 10), count: 20)
            service.save(
                gameBoard: board, currentTetromino: nil, nextTetromino: nil,
                gameLevel: GameLevel(), scoreSystem: ScoreSystem(), gameState: .paused,
                creationDate: Date(), lastPlayedDate: Date(), totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameBoard[0][0] == nil)
        }

        @Test func unknownColorSerializedAsNil() throws {
            let service = makeService()
            var board = Array(repeating: Array(repeating: Optional<Color>.none, count: 10), count: 20)
            board[0][0] = .black // not in the supported 7 colors
            service.save(
                gameBoard: board, currentTetromino: nil, nextTetromino: nil,
                gameLevel: GameLevel(), scoreSystem: ScoreSystem(), gameState: .paused,
                creationDate: Date(), lastPlayedDate: Date(), totalPlayTime: 0
            )
            let loaded = try #require(service.load())
            #expect(loaded.gameBoard[0][0] == nil)
        }

        // MARK: Static load

        @Test func staticLoadReturnsSavedState() {
            let service = makeService()
            service.save(
                gameBoard: Array(repeating: Array(repeating: nil, count: 10), count: 20),
                currentTetromino: nil,
                nextTetromino: nil,
                gameLevel: GameLevel(),
                scoreSystem: ScoreSystem(),
                gameState: .paused,
                creationDate: Date(),
                lastPlayedDate: Date(),
                totalPlayTime: 0
            )
            #expect(PersistenceService.loadSavedGameState() != nil)
        }

        // MARK: SwiftData session

        @Test func saveSessionInsertsRecord() throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: TetrisGameSession.self, configurations: config)
            let context = ModelContext(container)
            let service = PersistenceService(modelContext: context)

            service.saveSession(
                creationDate: Date(),
                completionDate: Date(),
                score: 500,
                level: 3,
                linesCleared: 12,
                playDuration: 60
            )

            let descriptor = FetchDescriptor<TetrisGameSession>()
            let sessions = try context.fetch(descriptor)
            #expect(sessions.count == 1)
            #expect(sessions[0].score == 500)
            #expect(sessions[0].level == 3)
        }

        @Test func saveMultipleSessionsInsertsMultipleRecords() throws {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: TetrisGameSession.self, configurations: config)
            let context = ModelContext(container)
            let service = PersistenceService(modelContext: context)

            service.saveSession(creationDate: Date(), completionDate: Date(), score: 100, level: 1, linesCleared: 3, playDuration: 30)
            service.saveSession(creationDate: Date(), completionDate: Date(), score: 200, level: 2, linesCleared: 7, playDuration: 60)

            let descriptor = FetchDescriptor<TetrisGameSession>()
            let sessions = try context.fetch(descriptor)
            #expect(sessions.count == 2)
        }

        @Test func saveSessionWithoutModelContextIsNoOp() throws {
            let service = PersistenceService(modelContext: nil)
            // Should not crash
            service.saveSession(creationDate: Date(), completionDate: Date(), score: 0, level: 1, linesCleared: 0, playDuration: 0)
        }
    }

    // MARK: - GameViewModel

    @Suite(.serialized)
    struct GameViewModelTests {

        private let gameStateKey = "TetrisCurrentGame"

        init() {
            UserDefaults.standard.removeObject(forKey: "TetrisCurrentGame")
        }

        // MARK: Initial state

        @Test @MainActor func initialStateIsWaiting() {
            let vm = GameViewModel()
            #expect(vm.gameState == .waiting)
        }

        @Test @MainActor func initialShowLevelUpAnimationIsFalse() {
            let vm = GameViewModel()
            #expect(vm.showLevelUpAnimation == false)
        }

        @Test @MainActor func initialBoardDimensions() {
            let vm = GameViewModel()
            #expect(vm.boardWidth == 10)
            #expect(vm.boardHeight == 20)
        }

        @Test @MainActor func initialBoardIsAllNil() {
            let vm = GameViewModel()
            for row in vm.gameBoard {
                for cell in row {
                    #expect(cell == nil)
                }
            }
        }

        @Test @MainActor func initialTetrominesAreNonNil() {
            let vm = GameViewModel()
            #expect(vm.currentTetromino != nil)
            #expect(vm.nextTetromino != nil)
        }

        @Test @MainActor func initialLevelIsOne() {
            let vm = GameViewModel()
            #expect(vm.gameLevel.level == 1)
        }

        @Test @MainActor func initialScoreIsZero() {
            let vm = GameViewModel()
            #expect(vm.scoreSystem.score == 0)
        }

        // MARK: State transitions

        @Test @MainActor func startGameSetsPlayingState() {
            let vm = GameViewModel()
            vm.startGame()
            #expect(vm.gameState == .playing)
            vm.pauseGame() // cleanup timer
        }

        @Test @MainActor func pauseGameSetsPausedState() {
            let vm = GameViewModel()
            vm.startGame()
            vm.pauseGame()
            #expect(vm.gameState == .paused)
        }

        @Test @MainActor func resumeGameSetsPlayingState() {
            let vm = GameViewModel()
            vm.startGame()
            vm.pauseGame()
            vm.resumeGame()
            #expect(vm.gameState == .playing)
            vm.pauseGame() // cleanup timer
        }

        @Test @MainActor func endGameSetsGameOverState() {
            let vm = GameViewModel()
            vm.startGame()
            vm.endGame()
            #expect(vm.gameState == .gameOver)
        }

        @Test @MainActor func resetGameFromPlayingSetsWaiting() {
            let vm = GameViewModel()
            vm.startGame()
            vm.resetGame()
            #expect(vm.gameState == .waiting)
        }

        @Test @MainActor func resetGameFromPausedSetsWaiting() {
            let vm = GameViewModel()
            vm.startGame()
            vm.pauseGame()
            vm.resetGame()
            #expect(vm.gameState == .waiting)
        }

        @Test @MainActor func resetGameFromGameOverSetsWaiting() {
            let vm = GameViewModel()
            vm.startGame()
            vm.endGame()
            vm.resetGame()
            #expect(vm.gameState == .waiting)
        }

        // MARK: Invalid transitions (no-ops)

        @Test @MainActor func pauseFromWaitingIsNoOp() {
            let vm = GameViewModel()
            vm.pauseGame()
            #expect(vm.gameState == .waiting)
        }

        @Test @MainActor func pauseFromPausedIsNoOp() {
            let vm = GameViewModel()
            vm.startGame()
            vm.pauseGame()
            let state = vm.gameState
            vm.pauseGame()
            #expect(vm.gameState == state)
        }

        @Test @MainActor func resumeFromWaitingIsNoOp() {
            let vm = GameViewModel()
            vm.resumeGame()
            #expect(vm.gameState == .waiting)
        }

        @Test @MainActor func resumeFromPlayingIsNoOp() {
            let vm = GameViewModel()
            vm.startGame()
            vm.resumeGame()
            #expect(vm.gameState == .playing)
            vm.pauseGame() // cleanup timer
        }

        @Test @MainActor func startGameWhenAlreadyPlayingIsNoOp() {
            let vm = GameViewModel()
            vm.startGame()
            vm.startGame() // should be no-op
            #expect(vm.gameState == .playing)
            vm.pauseGame() // cleanup timer
        }

        // MARK: Movement guards

        @Test @MainActor func moveLeftBlockedWhenPaused() {
            let vm = GameViewModel()
            vm.startGame()
            vm.pauseGame()
            let xBefore = vm.currentTetromino?.position.x ?? 0
            vm.moveLeft()
            let xAfter = vm.currentTetromino?.position.x ?? 0
            #expect(xBefore == xAfter)
        }

        @Test @MainActor func moveRightBlockedWhenWaiting() {
            let vm = GameViewModel()
            let xBefore = vm.currentTetromino?.position.x ?? 0
            vm.moveRight()
            let xAfter = vm.currentTetromino?.position.x ?? 0
            #expect(xBefore == xAfter)
        }

        @Test @MainActor func moveDownBlockedWhenPaused() {
            let vm = GameViewModel()
            vm.startGame()
            vm.pauseGame()
            let yBefore = vm.currentTetromino?.position.y ?? 0
            vm.moveDown()
            let yAfter = vm.currentTetromino?.position.y ?? 0
            #expect(yBefore == yAfter)
        }

        // MARK: Reset clears animation

        @Test @MainActor func resetClearsLevelUpAnimation() {
            let vm = GameViewModel()
            vm.showLevelUpAnimation = true
            vm.resetGame()
            #expect(vm.showLevelUpAnimation == false)
        }

        // MARK: Settings persistence

        @Test @MainActor func ghostBlocksDefaultIsTrue() {
            UserDefaults.standard.removeObject(forKey: "ghostBlocksEnabled")
            let vm = GameViewModel()
            #expect(vm.ghostBlocksEnabled == true)
        }

        @Test @MainActor func gameSoundDefaultIsTrue() {
            UserDefaults.standard.removeObject(forKey: "gameSoundEnabled")
            let vm = GameViewModel()
            #expect(vm.gameSoundEnabled == true)
        }

        @Test @MainActor func settingGhostBlocksWritesToUserDefaults() {
            let vm = GameViewModel()
            vm.ghostBlocksEnabled = false
            #expect(UserDefaults.standard.bool(forKey: "ghostBlocksEnabled") == false)
            vm.ghostBlocksEnabled = true // restore
        }

        @Test @MainActor func settingGameSoundWritesToUserDefaults() {
            let vm = GameViewModel()
            vm.gameSoundEnabled = false
            #expect(UserDefaults.standard.bool(forKey: "gameSoundEnabled") == false)
            vm.gameSoundEnabled = true // restore
        }

        @Test @MainActor func settingGameThemeWritesToUserDefaults() {
            let vm = GameViewModel()
            vm.gameTheme = 2
            #expect(UserDefaults.standard.integer(forKey: "gameTheme") == 2)
            vm.gameTheme = 0 // restore
        }

        // MARK: Init from saved state

        @Test @MainActor func initFromSavedStateRestoresGameState() {
            var scoreSystem = ScoreSystem()
            let savedState = SavedGameState(
                gameBoard: Array(repeating: Array(repeating: nil, count: 10), count: 20),
                currentTetromino: Tetromino(type: .t, startPosition: (x: 4, y: 0)),
                nextTetromino: Tetromino(type: .i, startPosition: (x: 4, y: 0)),
                gameLevel: GameLevel(),
                scoreSystem: scoreSystem,
                gameState: .paused,
                creationDate: Date(),
                lastPlayedDate: Date(),
                totalPlayTime: 42
            )
            let vm = GameViewModel(savedState: savedState)
            #expect(vm.gameState == .paused)
        }

        // MARK: Ghost piece

        @Test @MainActor func ghostPiecePositionIsNonNilWhenWaiting() {
            let vm = GameViewModel()
            // Ghost is computed from engine even when waiting
            #expect(vm.ghostPiecePosition != nil)
        }

        @Test @MainActor func ghostPieceAbsolutePositionsHaveFourBlocks() {
            let vm = GameViewModel()
            let positions = vm.ghostPieceAbsolutePositions()
            #expect(positions.count == 4)
        }
    }
}
