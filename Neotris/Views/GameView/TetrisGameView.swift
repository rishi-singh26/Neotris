//
//  TetrisGameView.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI
import AVFAudio

// Main game view
struct TetrisGameView: View {
    @EnvironmentObject var gameModel: TetrisGameModel

    var body: some View {
        ZStack {
            // Background
            GameBackgroundView()
            
            VStack(spacing: 10) {
                Text("Neotris")
                    .foregroundStyle(.white)
                    .font(.largeTitle.bold())
                    .fontDesign(.monospaced)
                
                ScoreBarView()
                
                HStack {
                    GameBoardView(gameModel: gameModel)
                    
                    GameRightView()
                }
                .padding(.horizontal, 10)
                
                ControlBarView()
            }
            
            // Level up animation overlay
            if gameModel.showLevelUpAnimation {
                LevelUpView()
            }
            
            // Game over overlay
            if gameModel.gameState == .gameOver {
                GameOverView()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    
                    if abs(horizontal) > abs(vertical) {
                        // Horizontal swipe
                        if horizontal > 20 {
                            gameModel.moveRight()
                        } else if horizontal < -20 {
                            gameModel.moveLeft()
                        }
                    } else {
                        // Vertical swipe
                        if vertical > 20 {
                            gameModel.moveDown()
                        } else if vertical < -20 {
                            gameModel.rotate()
                        }
                    }
                }
        )
    }
}

#Preview {
    TetrisGameView()
        .environmentObject(TetrisGameModel.shared)
}
