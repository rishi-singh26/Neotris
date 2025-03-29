//
//  GameBoardView.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI

// Game board view
struct GameBoardView: View {
    @ObservedObject var gameModel: TetrisGameModel
    
    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<gameModel.boardHeight, id: \.self) { y in
                HStack(spacing: 1) {
                    ForEach(0..<gameModel.boardWidth, id: \.self) { x in
                        cellView(x: x, y: y)
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.3))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.white, lineWidth: 2)
        )
    }
    
    @ViewBuilder
    private func cellView(x: Int, y: Int) -> some View {
        let size = cellSize()
        let ghostBlocks = gameModel.ghostPieceAbsolutePositions()
        
        if let color = gameModel.gameBoard[y][x] {
            // Cell with placed tetromino block
            Rectangle()
                .fill(color)
                .frame(width: size, height: size)
                .overlay(
                    Rectangle()
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
        } else if let current = gameModel.currentTetromino,
                  current.absoluteBlockPositions().contains(where: { $0.x == x && $0.y == y }) {
            // Current moving tetromino
            Rectangle()
                .fill(current.type.color)
                .frame(width: size, height: size)
                .overlay(
                    Rectangle()
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
        } else if ghostBlocks.contains(where: { $0.x == x && $0.y == y }),
                  let current = gameModel.currentTetromino {
            // Ghost piece
            Rectangle()
                .fill(Color.clear)
                .frame(width: size, height: size)
                .overlay(
                    Rectangle()
                        .stroke(current.type.color.opacity(0.5), lineWidth: 2)
                        .background(current.type.color.opacity(0.15))
                )
        } else {
            // Empty cell
            Rectangle()
                .fill(Color.black)
                .frame(width: size, height: size)
                .overlay(
                    Rectangle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                )
        }
    }
    
    // Calculate cell size based on available space
    private func cellSize() -> CGFloat {
        return min(
            (UIScreen.main.bounds.width - 40) / CGFloat(gameModel.boardWidth),
            (UIScreen.main.bounds.height - 300) / CGFloat(gameModel.boardHeight)
        )
    }
}

#Preview {
    TetrisGameView()
}
