//
//  NextPieceView.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI

// Next piece preview view
struct NextPieceView: View {
    @Environment(GameViewModel.self) private var viewModel
    var tetromino: Tetromino?

    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<4, id: \.self) { y in
                HStack(spacing: 1) {
                    ForEach(0..<4, id: \.self) { x in
                        if let type = tetromino?.type,
                           tetromino?.blocks.first(where: { $0.x == x && $0.y == y }) != nil {
                            CellBuilder(color: viewModel.tetrominoColor(for: type))
                        } else {
                            CellBuilder(color: .black.opacity(0.2))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func CellBuilder(color: Color) -> some View {
        let size = CGFloat(DeviceType.current == .iPhone ? 15 : 22.5)
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .cornerRadius(2)
            .padding(0.1)
    }
}

#Preview {
    TetrisGameView()
        .environment(GameViewModel())
}
