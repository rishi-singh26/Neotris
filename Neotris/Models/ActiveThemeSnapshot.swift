//
//  ActiveThemeSnapshot.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import SwiftUI

// MARK: - Active Theme Snapshot (stored in UserDefaults)

/// A lightweight, Codable snapshot of the active GameTheme stored in UserDefaults
/// so the game can use it without hitting SwiftData on every frame.
struct ActiveThemeSnapshot: Codable {
    let themeID: String
    let tetrominoColors: [String]
    let meshWidth: Int
    let meshHeight: Int
    let meshColors: [String]
    let meshPointsX: [Double]
    let meshPointsY: [Double]

    init(from theme: GameTheme) {
        self.themeID = theme.id.uuidString
        self.tetrominoColors = theme.tetrominoColors
        self.meshWidth = theme.meshWidth
        self.meshHeight = theme.meshHeight
        self.meshColors = theme.meshColors
        self.meshPointsX = theme.meshPointsX
        self.meshPointsY = theme.meshPointsY
    }

    /// SIMD2<Float> points suitable for MeshGradient
    var simdPoints: [SIMD2<Float>] {
        guard meshPointsX.count == meshPointsY.count else { return [] }
        return zip(meshPointsX, meshPointsY).map { SIMD2<Float>(Float($0), Float($1)) }
    }

    /// Resolved SwiftUI Colors from hex strings
    var resolvedMeshColors: [Color] {
        meshColors.map { Color(hex: $0) }
    }

    /// Returns the custom color for a tetromino type, falling back to the type's default
    func tetrominoColor(for type: TetrominoType) -> Color {
        guard let index = TetrominoType.allCases.firstIndex(of: type),
              index < tetrominoColors.count else { return type.color }
        return Color(hex: tetrominoColors[index])
    }
}
