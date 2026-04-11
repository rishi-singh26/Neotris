//
//  GameViewModel.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import SwiftUI
import Combine
import SwiftData
import Observation

@Observable
final class GameViewModel {
    // MARK: - Services (private, not observation-tracked)
    @ObservationIgnored private let engine: GameEngine
    @ObservationIgnored private let hapticService: HapticService
    @ObservationIgnored private let persistenceService: PersistenceService

    // MARK: - Game State
    var gameState: GameState = .waiting
    var showLevelUpAnimation: Bool = false

    // MARK: - Settings (stored vars backed by UserDefaults via didSet)
    var hapticFeedbackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticFeedbackEnabled, forKey: "hapticFeedbackEnabled")
            hapticFeedbackEnabled ? hapticService.prepare() : hapticService.stop()
        }
    }
    var ghostBlocksEnabled: Bool {
        didSet { UserDefaults.standard.set(ghostBlocksEnabled, forKey: "ghostBlocksEnabled") }
    }
    var gameTheme: Int {
        didSet { UserDefaults.standard.set(gameTheme, forKey: "gameTheme") }
    }
    var gameSoundEnabled: Bool {
        didSet { UserDefaults.standard.set(gameSoundEnabled, forKey: "gameSoundEnabled") }
    }

    // MARK: - Active Game Theme
    var activeThemeSnapshot: ActiveThemeSnapshot?

    // MARK: - Engine State Proxies
    // Views access these; observation chains through the @Observable GameEngine automatically.
    var gameBoard: [[TetrominoType?]] { engine.gameBoard }
    var currentTetromino: Tetromino? { engine.currentTetromino }
    var nextTetromino: Tetromino? { engine.nextTetromino }
    var secondNextTetromino: Tetromino? { engine.secondNextTetromino }
    var gameLevel: GameLevel { engine.gameLevel }
    var scoreSystem: ScoreSystem { engine.scoreSystem }
    var ghostPiecePosition: (x: Int, y: Int)? { engine.ghostPiecePosition }
    var boardWidth: Int { engine.boardWidth }
    var boardHeight: Int { engine.boardHeight }

    // MARK: - Time Tracking (not observed)
    @ObservationIgnored private var creationDate: Date = Date()
    @ObservationIgnored private var lastPlayedDate: Date = Date()
    @ObservationIgnored private var totalPlayTime: TimeInterval = 0
    @ObservationIgnored private var sessionStartTime: Date?

    // MARK: - Game Loop (not observed)
    @ObservationIgnored private var gameTimer: AnyCancellable?

    // MARK: - Init

    init(modelContext: ModelContext? = nil) {
        // Register UserDefaults defaults for boolean keys whose default is true
        UserDefaults.standard.register(defaults: [
            "ghostBlocksEnabled": true,
            "gameSoundEnabled": true
        ])

        self.engine = GameEngine()
        self.hapticService = HapticService()
        self.persistenceService = PersistenceService(modelContext: modelContext)

        // Load settings from UserDefaults (didSet doesn't fire during init)
        self.hapticFeedbackEnabled = UserDefaults.standard.bool(forKey: "hapticFeedbackEnabled")
        self.ghostBlocksEnabled = UserDefaults.standard.bool(forKey: "ghostBlocksEnabled")
        self.gameTheme = UserDefaults.standard.integer(forKey: "gameTheme")
        self.gameSoundEnabled = UserDefaults.standard.bool(forKey: "gameSoundEnabled")
        self.activeThemeSnapshot = Self.loadThemeSnapshot()

        if self.hapticFeedbackEnabled {
            self.hapticService.prepare()
        }
    }

    init(savedState: SavedGameState, modelContext: ModelContext? = nil) {
        UserDefaults.standard.register(defaults: [
            "ghostBlocksEnabled": true,
            "gameSoundEnabled": true
        ])

        self.engine = GameEngine(savedState: savedState)
        self.hapticService = HapticService()
        self.persistenceService = PersistenceService(modelContext: modelContext)

        self.hapticFeedbackEnabled = UserDefaults.standard.bool(forKey: "hapticFeedbackEnabled")
        self.ghostBlocksEnabled = UserDefaults.standard.bool(forKey: "ghostBlocksEnabled")
        self.gameTheme = UserDefaults.standard.integer(forKey: "gameTheme")
        self.gameSoundEnabled = UserDefaults.standard.bool(forKey: "gameSoundEnabled")
        self.activeThemeSnapshot = Self.loadThemeSnapshot()

        self.creationDate = savedState.creationDate
        self.lastPlayedDate = savedState.lastPlayedDate
        self.totalPlayTime = savedState.totalPlayTime
        self.gameState = savedState.gameState

        if self.hapticFeedbackEnabled {
            self.hapticService.prepare()
        }
    }

    // MARK: - Game Lifecycle

    func prepareHapticsIfEnabled() {
        if hapticFeedbackEnabled {
            hapticService.prepare()
        }
    }

    func startGame() {
        guard gameState != .playing else { return }
        withAnimation { gameState = .playing }
        sessionStartTime = Date()
        startGameLoop()
        saveCurrentState()
    }

    func pauseGame() {
        guard gameState == .playing else { return }
        withAnimation { gameState = .paused }
        stopGameLoop()
        hapticService.stop()
        accumulatePlayTime()
        saveCurrentState()
    }

    func resumeGame() {
        guard gameState == .paused else { return }
        withAnimation { gameState = .playing }
        sessionStartTime = Date()
        lastPlayedDate = Date()
        hapticService.prepare()
        startGameLoop()
        saveCurrentState()
    }

    func endGame() {
        withAnimation { gameState = .gameOver }
        stopGameLoop()
        hapticService.playGameOver(enabled: hapticFeedbackEnabled)
        accumulatePlayTime()
        let completionDate = Date()
        lastPlayedDate = completionDate
        persistenceService.saveSession(
            creationDate: creationDate,
            completionDate: completionDate,
            score: engine.scoreSystem.score,
            level: engine.gameLevel.level,
            linesCleared: engine.gameLevel.linesCleared,
            playDuration: totalPlayTime
        )
        persistenceService.clear()
    }

    func resetGame() {
        stopGameLoop()
        engine.reset()
        withAnimation { gameState = .waiting }
        showLevelUpAnimation = false
        creationDate = Date()
        lastPlayedDate = Date()
        totalPlayTime = 0
        sessionStartTime = nil
    }

    // MARK: - User Actions

    func moveLeft() {
        guard gameState == .playing else { return }
        if engine.moveLeft() {
            hapticService.playMovement(enabled: hapticFeedbackEnabled)
        }
    }

    func moveRight() {
        guard gameState == .playing else { return }
        if engine.moveRight() {
            hapticService.playMovement(enabled: hapticFeedbackEnabled)
        }
    }

    func moveDown() {
        guard gameState == .playing else { return }
        if engine.moveDown() {
            hapticService.playMovement(enabled: hapticFeedbackEnabled)
        }
    }

    func rotate() {
        guard gameState == .playing else { return }
        if engine.rotate() {
            hapticService.playRotation(enabled: hapticFeedbackEnabled)
        }
    }

    func hardDrop() {
        guard gameState == .playing else { return }
        engine.hardDrop()
        hapticService.playHardDrop(enabled: hapticFeedbackEnabled)
    }

    func ghostPieceAbsolutePositions() -> [Block] {
        engine.ghostPieceAbsolutePositions()
    }

    // MARK: - Private Game Loop

    private func startGameLoop() {
        gameTimer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.handleTick()
            }
    }

    private func stopGameLoop() {
        gameTimer?.cancel()
        gameTimer = nil
    }

    private func handleTick() {
        guard gameState == .playing else { return }

        let result = engine.tick()
        guard result.piecePlaced else { return }

        if result.linesCleared > 0 {
            hapticService.playLineClear(count: result.linesCleared, enabled: hapticFeedbackEnabled)
        }

        if result.didLevelUp {
            showLevelUpAnimation = true
            hapticService.playLevelUp(enabled: hapticFeedbackEnabled)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.showLevelUpAnimation = false
            }
        }

        if result.isGameOver {
            endGame()
        } else {
            saveCurrentState()
        }
    }

    // MARK: - Private Helpers

    private func accumulatePlayTime() {
        if let start = sessionStartTime {
            totalPlayTime += Date().timeIntervalSince(start)
            sessionStartTime = nil
        }
    }

    private func saveCurrentState() {
        guard gameState == .playing || gameState == .paused else { return }
        persistenceService.save(
            gameBoard: engine.gameBoard,
            currentTetromino: engine.currentTetromino,
            nextTetromino: engine.nextTetromino,
            gameLevel: engine.gameLevel,
            scoreSystem: engine.scoreSystem,
            gameState: gameState,
            creationDate: creationDate,
            lastPlayedDate: Date(),
            totalPlayTime: totalPlayTime
        )
    }

    // MARK: - Theme Management

    /// Applies a GameTheme: stores a snapshot in UserDefaults and updates the published property.
    func applyTheme(_ theme: GameTheme) {
        let snapshot = ActiveThemeSnapshot(from: theme)
        activeThemeSnapshot = snapshot
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: "activeGameTheme")
        }
    }

    /// Applies a BuiltInTheme. The Default built-in theme calls clearTheme() for backward compatibility.
    func applyBuiltInTheme(_ theme: BuiltInTheme) {
        if theme.id == BuiltInTheme.default.id {
            clearTheme()
            return
        }
        let snapshot = ActiveThemeSnapshot(from: theme)
        activeThemeSnapshot = snapshot
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: "activeGameTheme")
        }
    }

    /// Clears the active theme, reverting to built-in defaults.
    func clearTheme() {
        activeThemeSnapshot = nil
        UserDefaults.standard.removeObject(forKey: "activeGameTheme")
    }

    /// Returns the correct color for a tetromino type respecting the active theme.
    func tetrominoColor(for type: TetrominoType) -> Color {
        activeThemeSnapshot?.tetrominoColor(for: type) ?? type.color
    }

    private static func loadThemeSnapshot() -> ActiveThemeSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: "activeGameTheme") else { return nil }
        return try? JSONDecoder().decode(ActiveThemeSnapshot.self, from: data)
    }
}
