//
//  GameOverView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var gameModel: TetrisGameModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Game Over")
            .font(.largeTitle.bold())
            .padding(.bottom, -1)
            .padding(.leading, 4)
            
            HStack {
                Spacer()
                VStack {
                    Text("HIGH SCORE")
                        .font(.body)
                        .padding(.top, 2)
                    Text(String(gameModel.scoreSystem.highScore))
                        .font(.title2.bold())
                }
                Spacer()
                VStack {
                    Text("SCORE")
                        .font(.body)
                        .padding(.top, 4)
                    Text(String(gameModel.scoreSystem.score))
                        .font(.title2.bold())
                }
                Spacer()
                VStack {
                    Text("LEVEL")
                        .font(.body)
                        .padding(.top, 4)
                    Text("\(gameModel.gameLevel.level)")
                        .font(.title2.bold())
                }
                Spacer()
            }
            .padding(.vertical, 30)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            
            HStack {
                Spacer()
                Button(action: {
                    gameModel.resetGame()
                }) {
                    HStack(spacing: gameModel.gameState == .playing ? 0 : 15) {
                        Image(systemName: "plus.circle.fill")
                        Text("New Game")
                    }
                    .padding(.horizontal, 60)
                    .frame(width: gameModel.gameState == .playing ? 65 : nil, height: 65)
                    .background(.thinMaterial)
                    .font(.title2.bold())
                    .cornerRadius(20)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
        .padding(.top, 20)
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .padding(8)
        .frame(maxWidth: 400)
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: gameModel.gameState == .gameOver)
        .environment(\.colorScheme, .dark)
    }
}

#Preview {
    GameOverView()
        .environmentObject(TetrisGameModel.shared)
}
