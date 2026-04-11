//
//  TetrisGameSession.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

import Foundation
import SwiftData


enum TetrisGameSessionSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [TetrisGameSession.self]
    }
    // Game session data for SwiftData storage
    @Model
    class TetrisGameSession {
        var creationDate: Date = Date()
        var completionDate: Date = Date()
        var score: Int = 0
        var level: Int = 1
        var linesCleared: Int = 0
        var playDuration: TimeInterval = 0.0
        
        init(creationDate: Date = Date(), completionDate: Date = Date(), score: Int = 0, level: Int = 1, linesCleared: Int = 0, playDuration: TimeInterval = 0.0) {
            self.creationDate = creationDate
            self.completionDate = completionDate
            self.score = score
            self.level = level
            self.linesCleared = linesCleared
            self.playDuration = playDuration
        }
    }
}

enum NeotrisV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [TetrisGameSession.self, GameTheme.self]
    }
    // Game session data for SwiftData storage
    @Model
    class TetrisGameSession {
        var creationDate: Date = Date()
        var completionDate: Date = Date()
        var score: Int = 0
        var level: Int = 1
        var linesCleared: Int = 0
        var playDuration: TimeInterval = 0.0
        
        init(creationDate: Date = Date(), completionDate: Date = Date(), score: Int = 0, level: Int = 1, linesCleared: Int = 0, playDuration: TimeInterval = 0.0) {
            self.creationDate = creationDate
            self.completionDate = completionDate
            self.score = score
            self.level = level
            self.linesCleared = linesCleared
            self.playDuration = playDuration
        }
    }
    
    @Model
    class GameTheme {
        var id: UUID = UUID()
        var name: String = ""
        var creationDate: Date = Date.now
        /// Hex color strings (no '#') for each TetrominoType in allCases order: i, o, t, j, l, s, z
        var tetrominoColors: [String] = GameTheme.defaultTetrominoHexColors
        var meshWidth: Int = 3
        var meshHeight: Int = 4
        /// Hex color strings for each MeshGradient point (count = meshWidth × meshHeight)
        var meshColors: [String] = GameTheme.defaultMeshHexColors
        /// Normalized X coordinates for each MeshGradient point (0...1)
        var meshPointsX: [Double] = GameTheme.defaultMeshPointsX
        /// Normalized Y coordinates for each MeshGradient point (0...1)
        var meshPointsY: [Double] = GameTheme.defaultMeshPointsY

        init(name: String, themeIndex: Int = 0) {
            self.id = UUID()
            self.name = name.isEmpty ? "Theme \(themeIndex + 1)" : name
            self.creationDate = Date()
            self.tetrominoColors = GameTheme.defaultTetrominoHexColors
            self.meshWidth = 3
            self.meshHeight = 4
            self.meshColors = GameTheme.defaultMeshHexColors
            self.meshPointsX = GameTheme.defaultMeshPointsX
            self.meshPointsY = GameTheme.defaultMeshPointsY
        }
    }
}

typealias TetrisGameSession = NeotrisV2.TetrisGameSession
typealias GameTheme = NeotrisV2.GameTheme

extension GameTheme {
    // MARK: - Default Color Values

    /// Default tetromino hex colors in TetrominoType.allCases order: i, o, t, j, l, s, z
    static let defaultTetrominoHexColors: [String] = [
        "00FFFF",   // I – cyan
        "FFFF00",   // O – yellow
        "AF52DE",   // T – purple
        "007AFF",   // J – blue
        "FF9500",   // L – orange
        "34C759",   // S – green
        "FF3B30"    // Z – red
    ]

    /// Default mesh gradient colors mirroring GameBackgroundView's hardcoded values
    static let defaultMeshHexColors: [String] = [
        "FDA504", "F78A12", "F68913",
        "FF3C2F", "AC537F", "D66A4F",
        "DE7A1C", "996062", "5856D6",
        "FF2C55", "DA9F26", "E7B438"
    ]

    /// Default X coordinates for the 3×4 mesh (mirrors GameBackgroundView)
    static let defaultMeshPointsX: [Double] = [
        0, 0.5, 1.0,
        0, 0.5, 1.0,
        0, 0.5, 1.0,
        0, 0.5, 1.0
    ]

    /// Default Y coordinates for the 3×4 mesh (mirrors GameBackgroundView)
    static let defaultMeshPointsY: [Double] = [
        0,   0,   0,
        0.4, 0.4, 0.4,
        0.7, 0.7, 0.7,
        1.0, 1.0, 1.0
    ]

    // MARK: - Grid Helpers

    /// Evenly distributed X coordinates for an arbitrary grid size
    static func evenPointsX(width: Int, height: Int) -> [Double] {
        var pts: [Double] = []
        for _ in 0..<height {
            for col in 0..<width {
                pts.append(width == 1 ? 0.5 : Double(col) / Double(width - 1))
            }
        }
        return pts
    }

    /// Evenly distributed Y coordinates for an arbitrary grid size
    static func evenPointsY(width: Int, height: Int) -> [Double] {
        var pts: [Double] = []
        for row in 0..<height {
            for _ in 0..<width {
                pts.append(height == 1 ? 0.5 : Double(row) / Double(height - 1))
            }
        }
        return pts
    }
}
