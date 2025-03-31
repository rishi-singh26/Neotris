//
//  ControlBarView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct ControlBarView: View {
    @EnvironmentObject var gameModel: TetrisGameModel
    
    var body: some View {
        HStack {
            if gameModel.gameState == .playing {
                ControlButton(iconName: "chevron.left") {
                    gameModel.moveLeft()
                }
                Spacer()
                ControlButton(iconName: "arrow.down.to.line.compact") {
                    gameModel.hardDrop()
                }
            }
            Spacer()
            
            Button(action: {
                if gameModel.gameState == .waiting {
                    gameModel.startGame()
                } else if gameModel.gameState == .gameOver {
                    gameModel.resetGame()
                    gameModel.startGame()
                } else if gameModel.gameState == .playing {
                    gameModel.pauseGame()
                } else if gameModel.gameState == .paused {
                    gameModel.resumeGame()
                }
            }) {
                HStack(spacing: gameModel.gameState == .playing ? 0 : 15) {
                    Image(systemName: buttonIcon)
                    if gameModel.gameState != .playing {
                        Text(buttonText)
                    }
                }
                .padding(.horizontal, 30)
                .frame(width: gameModel.gameState == .playing ? 65 : nil, height: 65)
                .background(.thinMaterial)
                .font(.title2.bold())
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            if gameModel.gameState == .playing {
                ControlButton(iconName: "arrow.trianglehead.counterclockwise.rotate.90") {
                    gameModel.rotate()
                }
                Spacer()
                ControlButton(iconName: "chevron.right") {
                    gameModel.moveRight()
                }
            }
        }
        .padding(10)
        .frame(maxWidth: UIService.screenWidth - 10)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal, DeviceType.current == .iPhone ? 10 : 100)
    }
    
    // Button text changes based on game state
    private var buttonIcon: String {
        switch gameModel.gameState {
        case .waiting:
            return "play.fill"
        case .playing:
            return "pause.fill"
        case .paused:
            return "play.fill"
        case .gameOver:
            return "plus.circle.fill"
        }
    }
    
    private var buttonText: String {
        switch gameModel.gameState {
        case .waiting:
            return "Start"
        case .playing:
            return ""
        case .paused:
            return "Resume"
        case .gameOver:
            return "Start New Game"
        }
    }
}

#Preview {
    TetrisGameView()
        .environmentObject(TetrisGameModel.shared)
//    ControlBarView()
//        .environmentObject(TetrisGameModel.shared)
}
