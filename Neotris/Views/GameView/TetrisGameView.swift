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
    @StateObject private var gameModel = TetrisGameModel()
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Game info
                HStack {
                    VStack(alignment: .leading) {
                        Text("Score: \(gameModel.scoreSystem.score)")
                            .font(.headline)
                        
                        HStack {
                            Text("Level: \(gameModel.gameLevel.level)")
                                .font(.headline)
                            
                            // New: Speed indicator
                            Text("(\(gameModel.gameLevel.speedPercentage)% speed)")
                                .font(.caption)
                                .foregroundColor(speedColor())
                        }
                        
                        // New: Progress to next level
                        HStack(spacing: 0) {
                            Text("Next level: ")
                                .font(.caption)
                            
                            Text("\(gameModel.gameLevel.linesToNextLevel) lines")
                                .font(.caption)
                                .bold()
                        }
                        
                        Text("High Score: \(gameModel.scoreSystem.highScore)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                    
                    // Next piece preview
                    VStack {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        NextPieceView(tetromino: gameModel.nextTetromino)
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .padding()
                }
                
                // Game board
                GameBoardView(gameModel: gameModel)
                    .padding()
                
                // Controls
                VStack {
                    HStack(spacing: 30) {
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
                            Text(buttonText)
                                .frame(width: 100, height: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top)
                    
                    HStack(spacing: 40) {
                        Button(action: { gameModel.moveLeft() }) {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Color.gray.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        VStack {
                            Button(action: { gameModel.rotate() }) {
                                Image(systemName: "arrow.up")
                                    .font(.title)
                                    .frame(width: 60, height: 60)
                                    .background(Color.gray.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: { gameModel.moveDown() }) {
                                Image(systemName: "arrow.down")
                                    .font(.title)
                                    .frame(width: 60, height: 60)
                                    .background(Color.gray.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Button(action: { gameModel.moveRight() }) {
                            Image(systemName: "arrow.right")
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Color.gray.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top)
                    
                    Button(action: { gameModel.hardDrop() }) {
                        Text("Hard Drop")
                            .frame(width: 120, height: 44)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top)
                }
                .padding(.bottom)
            }
            
            // Level up animation overlay
            if gameModel.showLevelUpAnimation {
                VStack {
                    Text("LEVEL UP!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    
                    Text("Level \(gameModel.gameLevel.level)")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    if gameModel.gameLevel.level > 1 {
                        Text("Speed: \(gameModel.gameLevel.speedPercentage)%")
                            .font(.headline)
                            .foregroundColor(speedColor())
                            .padding(.top, 8)
                    }
                }
                .padding(30)
                .background(Color.black.opacity(0.7))
                .cornerRadius(15)
                .transition(.scale.combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: gameModel.showLevelUpAnimation)
            }
            
            // Game over overlay
            if gameModel.gameState == .gameOver {
                VStack {
                    Text("Game Over")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Text("Score: \(gameModel.scoreSystem.score)")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Level: \(gameModel.gameLevel.level)")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    
                    Button("Play Again") {
                        gameModel.resetGame()
                        gameModel.startGame()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top)
                }
                .padding(40)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
            }
            
            // Pause overlay
            if gameModel.gameState == .paused {
                VStack {
                    Text("Game Paused")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Button("Resume") {
                        gameModel.resumeGame()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top)
                }
                .padding(40)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
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
        .gesture(
            TapGesture(count: 2)
                .onEnded {
                    gameModel.hardDrop()
                }
        )
    }
    
    // Button text changes based on game state
    private var buttonText: String {
        switch gameModel.gameState {
        case .waiting:
            return "Start"
        case .playing:
            return "Pause"
        case .paused:
            return "Resume"
        case .gameOver:
            return "Restart"
        }
    }
    
    // Color for the speed indicator based on game speed
    private func speedColor() -> Color {
        let speed = gameModel.gameLevel.speedPercentage
        switch speed {
        case 0...20:
            return .green
        case 21...50:
            return .yellow
        case 51...75:
            return .orange
        default:
            return .red
        }
    }
}

#Preview {
    TetrisGameView()
}
