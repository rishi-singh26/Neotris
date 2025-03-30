//
//  GameRightView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct GameRightView: View {
    @EnvironmentObject var gameModel: TetrisGameModel
    @Binding var showSettingsSheet: Bool
    @Binding var showInstructionSheet: Bool
    @Binding var showSessionSheet: Bool
    
    var body: some View {
        VStack {
            VStack {
                NextPieceView(tetromino: gameModel.nextTetromino)
                NextPieceView(tetromino: gameModel.secondNextTetromino)
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            
//                        Spacer()
            
            VStack {
                ControlButton(iconName: "questionmark.circle.fill") {
                    gameModel.pauseGame()
                    showInstructionSheet = true
                }
                
                ControlButton(iconName: "list.dash") {
                    gameModel.pauseGame()
                    showSessionSheet = true
                }
//                            Spacer()
                ControlButton(iconName: "switch.2") {
                    gameModel.pauseGame()
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
//    TetrisGameView()
        .environmentObject(TetrisGameModel.shared)
}
