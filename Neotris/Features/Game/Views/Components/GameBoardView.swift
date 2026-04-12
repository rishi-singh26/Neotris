//
//  GameBoardView.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI

struct GameBoardView: View {
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<viewModel.boardHeight, id: \.self) { y in
                HStack(spacing: 1) {
                    ForEach(0..<viewModel.boardWidth, id: \.self) { x in
                        cellView(x: x, y: y)
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }

    @ViewBuilder
    private func cellView(x: Int, y: Int) -> some View {
        let ghostBlocks = viewModel.ghostPieceAbsolutePositions()

        if let type = viewModel.gameBoard[y][x] {
            CellBuilder(color: viewModel.tetrominoColor(for: type))
        } else if let current = viewModel.currentTetromino,
                  current.absoluteBlockPositions().contains(where: { $0.x == x && $0.y == y }) {
            CellBuilder(color: viewModel.tetrominoColor(for: current.type))
        } else if viewModel.ghostBlocksEnabled,
                  ghostBlocks.contains(where: { $0.x == x && $0.y == y }),
                  let current = viewModel.currentTetromino {
            CellBuilder(color: viewModel.tetrominoColor(for: current.type).opacity(0.4))
        } else {
            CellBuilder(color: .black.opacity(0.2))
        }
    }

    @ViewBuilder
    private func CellBuilder(color: Color) -> some View {
        let size = cellSize()
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .cornerRadius(2)
            .padding(0.1)
    }

    private func cellSize() -> CGFloat {
#if os(iOS) || os(visionOS)
        let widthDivider = 17.47
        let heightDivider = 38.0
#elseif os(macOS)
        let widthDivider = 18.47
        let heightDivider = 39.0
#endif
        return min(
            UIService.screenWidth / widthDivider,
            UIService.screenHeight / heightDivider
        )
    }
}

#Preview {
    TetrisGameView()
        .environment(GameViewModel())
}
