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
                
                ControlButton(iconName: "list.dash") {
                    gameModel.rotate()
                }
//                            Spacer()
                ControlButton(iconName: "switch.2") {
                    gameModel.pauseGame()
                    showSettingsSheet = true;
                }
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
    }
}

#Preview {
    GameRightView(showSettingsSheet: .constant(false))
//    TetrisGameView()
        .environmentObject(TetrisGameModel.shared)
}
