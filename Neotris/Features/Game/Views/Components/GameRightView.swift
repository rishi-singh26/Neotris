//
//  GameRightView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct GameRightView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Binding var showSettingsSheet: Bool
    @Binding var showInstructionSheet: Bool
    @Binding var showSessionSheet: Bool

    var body: some View {
        VStack {
            VStack {
                NextPieceView(tetromino: viewModel.nextTetromino)
                NextPieceView(tetromino: viewModel.secondNextTetromino)
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .cornerRadius(20)

            VStack {
                ControlButton(iconName: "questionmark.circle.fill") {
                    viewModel.pauseGame()
                    showInstructionSheet = true
                }
                ControlButton(iconName: "list.dash") {
                    viewModel.pauseGame()
                    showSessionSheet = true
                }
                ControlButton(iconName: "switch.2") {
                    viewModel.pauseGame()
                    showSettingsSheet = true
                }
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
    }
}

#Preview {
    GameRightView(
        showSettingsSheet: .constant(false),
        showInstructionSheet: .constant(false),
        showSessionSheet: .constant(false)
    )
    .environment(GameViewModel())
}
