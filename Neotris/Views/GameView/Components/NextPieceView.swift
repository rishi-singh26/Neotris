//
//  NextPieceView.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI

// Next piece preview view
struct NextPieceView: View {
    var tetromino: Tetromino?
    
    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<4, id: \.self) { y in
                HStack(spacing: 1) {
                    ForEach(0..<4, id: \.self) { x in
                        if let _ = tetromino?.blocks.first(where: { block in
                            block.x == x && block.y == y
                        }) {
                            CellBuilder(color: tetromino?.type.color ?? .black.opacity(0.2))
                        } else {
                            CellBuilder(color: .black.opacity(0.2))
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func cellView(x: Int, y: Int) -> some View {
        if let _ = tetromino?.blocks.first(where: { block in
            block.x == x && block.y == y
        }) {
            CellBuilder(color: tetromino?.type.color ?? .black.opacity(0.2))
        } else {
            CellBuilder(color: .black.opacity(0.2))
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
        .environmentObject(TetrisGameModel.shared)
}
