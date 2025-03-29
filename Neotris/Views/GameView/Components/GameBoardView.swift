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
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
    
    @ViewBuilder
    private func cellView(x: Int, y: Int) -> some View {
        let ghostBlocks = gameModel.ghostPieceAbsolutePositions()
        
        if let color = gameModel.gameBoard[y][x] {
            // Cell with placed tetromino block
//            CellBuilder(color: "000000")
            CellBuilder(color: color)
        } else if let current = gameModel.currentTetromino,
                  current.absoluteBlockPositions().contains(where: { $0.x == x && $0.y == y }) {
            // Current moving tetromino
            CellBuilder(color: current.type.color)
        } else if gameModel.ghostBlocksEnabled && ghostBlocks.contains(where: { $0.x == x && $0.y == y }),
                  let current = gameModel.currentTetromino {
            // Ghost piece
            CellBuilder(color: current.type.color.opacity(0.4))
        } else {
            // Empty cell
            CellBuilder(color: .black.opacity(0.2))
        }
    }
    
//    @ViewBuilder
//    private func cellView(x: Int, y: Int) -> some View {
//        let ghostBlocks = gameModel.ghostPieceAbsolutePositions()
//        
//        if let color = gameModel.gameBoard[y][x] {
//            // Cell with placed tetromino block
//            CellBuilder(color: "000000")
//        } else if let current = gameModel.currentTetromino,
//                  current.absoluteBlockPositions().contains(where: { $0.x == x && $0.y == y }) {
//            // Current moving tetromino
//            CellBuilder(color: "000000")
//        } else if ghostBlocks.contains(where: { $0.x == x && $0.y == y }) {
//            // Ghost piece
//            CellBuilder(color: "00000077")
//        } else {
//            // Empty cell
//            CellBuilder(color: "00000033")
//        }
//    }
    
    @ViewBuilder
    private func CellBuilder(color: Color) -> some View {
        let size = cellSize()
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .cornerRadius(2)
            .padding(0.1)
    }
    
//    @ViewBuilder
//    private func CellBuilder(color: Color) -> some View {
//        let size = cellSize()
//        Rectangle()
//            .fill(color)
//            .frame(width: size-12, height: size-12)
//            .padding(5)
//            .overlay(
//                Rectangle()
//                    .stroke(color, lineWidth: 4)
//                    .background(.clear)
//            )
//            .padding(2)
//            .cornerRadius(4)
//    }
    
    // Calculate cell size based on available space
    private func cellSize() -> CGFloat {
//        print(UIService.screenWidth/17.47)
//        print(UIService.screenHeight/38)
//        return 23
        
//        return min(
//            (UIScreen.main.bounds.width - 40) / CGFloat(gameModel.boardWidth),
//            (UIScreen.main.bounds.height - 300) / CGFloat(gameModel.boardHeight)
//        )
        return min(
            (UIService.screenWidth / 17.47),
            (UIService.screenHeight / 38)
        )
    }
}

#Preview {
    TetrisGameView()
        .environmentObject(TetrisGameModel.shared)
}
