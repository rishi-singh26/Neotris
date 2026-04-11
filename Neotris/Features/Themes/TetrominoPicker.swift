//
//  TetrominoPicker.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import SwiftUI

// MARK: - Tetromino Picker Panel

/// Left panel (Mac/iPad) or bottom panel (iPhone) showing all 7 tetromino type
/// buttons and a Background button.
struct TetrominoPicker: View {
    @Binding var tetrominoColors: [Color]
    @Binding var selectedTetrominoIndex: Int
    var isBackgroundSelected: Bool
    var onTetrominoTap: (Int) -> Void
    var onBackgroundTap: () -> Void

    private let columns2 = [GridItem(.flexible()), GridItem(.flexible())]
    private let columns4 = [GridItem(.flexible()), GridItem(.flexible()),
                             GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: columns2, spacing: 8) {
                ForEach(TetrominoType.allCases.indices, id: \.self) { index in
                    TetrominoButton(
                        type: TetrominoType.allCases[index],
                        color: tetrominoColors[index],
                        isSelected: selectedTetrominoIndex == index && !isBackgroundSelected,
                        cellSize: 10
                    )
                    .onTapGesture { onTetrominoTap(index) }
                }
            }

            backgroundButton
        }
    }

    private var backgroundButton: some View {
        Button(action: onBackgroundTap) {
            Text("Background")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isBackgroundSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundStyle(isBackgroundSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tetromino Button

private struct TetrominoButton: View {
    let type: TetrominoType
    let color: Color
    let isSelected: Bool
    let cellSize: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? color.opacity(0.25) : Color.secondary.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isSelected ? color : Color.clear, lineWidth: 2)
                )

            TetrominoShapeView(type: type, color: color, cellSize: cellSize)
                .padding(6)
        }
        .frame(height: DeviceType.isIphone ? 44 : 54)
    }
}

// MARK: - Tetromino Shape View

/// Renders a small pixel-art representation of a tetromino type.
struct TetrominoShapeView: View {
    let type: TetrominoType
    let color: Color
    let cellSize: CGFloat

    var body: some View {
        let blocks = type.blocks
        let maxX = (blocks.map(\.x).max() ?? 0)
        let maxY = (blocks.map(\.y).max() ?? 0)

        VStack(spacing: 1) {
            ForEach(0...maxY, id: \.self) { y in
                HStack(spacing: 1) {
                    ForEach(0...maxX, id: \.self) { x in
                        let filled = blocks.contains(where: { $0.x == x && $0.y == y })
                        Rectangle()
                            .fill(filled ? color : Color.clear)
                            .frame(width: cellSize, height: cellSize)
                            .cornerRadius(1)
                    }
                }
            }
        }
    }
}
