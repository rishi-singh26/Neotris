//
//  BuiltInTheme.swift
//  Neotris
//
//  Created by Rishi Singh on 11/04/25.
//

import Foundation

/// A hardcoded built-in theme. Not stored in SwiftData — pure static Swift data.
struct BuiltInTheme: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    /// Hex color strings for each TetrominoType in allCases order: i, o, t, j, l, s, z
    let tetrominoColors: [String]
    let meshWidth: Int
    let meshHeight: Int
    /// Hex color strings for each MeshGradient point
    let meshColors: [String]
    let meshPointsX: [Double]
    let meshPointsY: [Double]

    // MARK: - All built-in themes

    static let all: [BuiltInTheme] = [.default, .dark, .neon, .ocean, .sunset, .pastel]

    // Shared 3×4 mesh point layout used by all built-in themes (mirrors GameTheme defaults)
    private static let pts3x4X: [Double] = [
        0, 0.5, 1.0,
        0, 0.5, 1.0,
        0, 0.5, 1.0,
        0, 0.5, 1.0
    ]
    private static let pts3x4Y: [Double] = [
        0,   0,   0,
        0.4, 0.4, 0.4,
        0.7, 0.7, 0.7,
        1.0, 1.0, 1.0
    ]

    // MARK: - Default

    // These color values deliberately mirror GameTheme.default* constants to stay in sync.
    static let `default` = BuiltInTheme(
        id: "builtin-default",
        name: "Default",
        tetrominoColors: [
            "00FFFF",   // I – cyan
            "FFFF00",   // O – yellow
            "AF52DE",   // T – purple
            "007AFF",   // J – blue
            "FF9500",   // L – orange
            "34C759",   // S – green
            "FF3B30"    // Z – red
        ],
        meshWidth: 3,
        meshHeight: 4,
        meshColors: [
            "FDA504", "F78A12", "F68913",
            "FF3C2F", "AC537F", "D66A4F",
            "DE7A1C", "996062", "5856D6",
            "FF2C55", "DA9F26", "E7B438"
        ],
        meshPointsX: pts3x4X,
        meshPointsY: pts3x4Y
    )

    // MARK: - Dark

    static let dark = BuiltInTheme(
        id: "builtin-dark",
        name: "Dark",
        tetrominoColors: [
            "00F5FF",   // I – bright cyan
            "FFE600",   // O – bright yellow
            "BF5FFF",   // T – vivid purple
            "0A84FF",   // J – vivid blue
            "FF6E00",   // L – vivid orange
            "30D158",   // S – vivid green
            "FF375F"    // Z – vivid red
        ],
        meshWidth: 3,
        meshHeight: 4,
        meshColors: [
            "1A1A2E", "16213E", "0F3460",
            "1C1C1E", "252535", "2C2C3E",
            "111118", "1A1A2E", "222235",
            "0D0D14", "111827", "1A1A2E"
        ],
        meshPointsX: pts3x4X,
        meshPointsY: pts3x4Y
    )

    // MARK: - Neon

    static let neon = BuiltInTheme(
        id: "builtin-neon",
        name: "Neon",
        tetrominoColors: [
            "00FFFF",   // I – electric cyan
            "FFFF00",   // O – electric yellow
            "FF00FF",   // T – electric magenta
            "00FF41",   // J – matrix green
            "FF6600",   // L – electric orange
            "00FF87",   // S – electric mint
            "FF003C"    // Z – electric red
        ],
        meshWidth: 3,
        meshHeight: 4,
        meshColors: [
            "050508", "0A000F", "050508",
            "0D0021", "19003A", "0A0021",
            "120030", "0A1540", "0D0028",
            "000D05", "00100A", "000805"
        ],
        meshPointsX: pts3x4X,
        meshPointsY: pts3x4Y
    )

    // MARK: - Ocean

    static let ocean = BuiltInTheme(
        id: "builtin-ocean",
        name: "Ocean",
        tetrominoColors: [
            "00B4D8",   // I – sky blue
            "90E0EF",   // O – light cyan
            "48CAE4",   // T – turquoise
            "0077B6",   // J – deep blue
            "023E8A",   // L – dark navy
            "00F5D4",   // S – seafoam
            "0096C7"    // Z – ocean blue
        ],
        meshWidth: 3,
        meshHeight: 4,
        meshColors: [
            "03045E", "023E8A", "03045E",
            "0077B6", "0096C7", "0077B6",
            "00B4D8", "48CAE4", "00B4D8",
            "90E0EF", "ADE8F4", "90E0EF"
        ],
        meshPointsX: pts3x4X,
        meshPointsY: pts3x4Y
    )

    // MARK: - Sunset

    static let sunset = BuiltInTheme(
        id: "builtin-sunset",
        name: "Sunset",
        tetrominoColors: [
            "FF6B6B",   // I – coral red
            "FFD166",   // O – golden yellow
            "C77DFF",   // T – purple
            "FF9F43",   // J – orange
            "FF4757",   // L – red-orange
            "A29BFE",   // S – lavender
            "FD79A8"    // Z – pink
        ],
        meshWidth: 3,
        meshHeight: 4,
        meshColors: [
            "FF4500", "FF6348", "FF4500",
            "FF7F50", "FF6B35", "E55039",
            "C85A11", "8E3A59", "B5446E",
            "7B2D8B", "6C3483", "7B2D8B"
        ],
        meshPointsX: pts3x4X,
        meshPointsY: pts3x4Y
    )

    // MARK: - Pastel

    static let pastel = BuiltInTheme(
        id: "builtin-pastel",
        name: "Pastel",
        tetrominoColors: [
            "A8DADC",   // I – soft teal
            "FFE8B6",   // O – soft yellow
            "D4A4F5",   // T – soft purple
            "A8C7E8",   // J – soft blue
            "FFBE7D",   // L – soft orange
            "B5EAD7",   // S – soft mint
            "FFB3C6"    // Z – soft pink
        ],
        meshWidth: 3,
        meshHeight: 4,
        meshColors: [
            "E8D5F5", "F0E6FF", "E8D5F5",
            "D8EEF5", "E6F4F8", "D8EEF5",
            "DCF5E8", "EAF8EF", "DCF5E8",
            "F5E6E8", "F8ECED", "F5E8F0"
        ],
        meshPointsX: pts3x4X,
        meshPointsY: pts3x4Y
    )
}
