//
//  PersistenceService.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import SwiftUI
import SwiftData

final class PersistenceService {
    var modelContext: ModelContext?

    private static let gameStateKey = "TetrisCurrentGame"

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    // MARK: - In-progress game (UserDefaults)

    func save(
        gameBoard: [[Color?]],
        currentTetromino: Tetromino?,
        nextTetromino: Tetromino?,
        gameLevel: GameLevel,
        scoreSystem: ScoreSystem,
        gameState: GameState,
        creationDate: Date,
        lastPlayedDate: Date,
        totalPlayTime: TimeInterval
    ) {
        var boardColors: [[String?]] = Array(
            repeating: Array(repeating: nil, count: gameBoard[0].count),
            count: gameBoard.count
        )
        for y in 0..<gameBoard.count {
            for x in 0..<gameBoard[y].count {
                boardColors[y][x] = colorName(for: gameBoard[y][x])
            }
        }

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

        do {
            let data = try JSONEncoder().encode(savedState)
            UserDefaults.standard.set(data, forKey: Self.gameStateKey)
        } catch {
            print("Failed to save game state: \(error)")
        }
    }

    func load() -> SavedGameState? {
        Self.loadSavedGameState()
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Self.gameStateKey)
    }

    // MARK: - Completed game (SwiftData)

    func saveSession(
        creationDate: Date,
        completionDate: Date,
        score: Int,
        level: Int,
        linesCleared: Int,
        playDuration: TimeInterval
    ) {
        guard let modelContext else { return }
        let session = TetrisGameSession(
            creationDate: creationDate,
            completionDate: completionDate,
            score: score,
            level: level,
            linesCleared: linesCleared,
            playDuration: playDuration
        )
        modelContext.insert(session)
        do {
            try modelContext.save()
        } catch {
            print("Failed to save completed game: \(error)")
        }
    }

    // MARK: - Static convenience (used at app launch before instance exists)

    static func loadSavedGameState() -> SavedGameState? {
        guard let data = UserDefaults.standard.data(forKey: gameStateKey) else { return nil }
        return try? JSONDecoder().decode(SavedGameState.self, from: data)
    }

    // MARK: - Private helpers

    private func colorName(for color: Color?) -> String? {
        guard let color else { return nil }
        if color == .cyan { return "cyan" }
        if color == .yellow { return "yellow" }
        if color == .purple { return "purple" }
        if color == .blue { return "blue" }
        if color == .orange { return "orange" }
        if color == .green { return "green" }
        if color == .red { return "red" }
        return nil
    }
}
