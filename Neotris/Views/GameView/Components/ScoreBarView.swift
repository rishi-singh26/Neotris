//
//  ScoreBarView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct ScoreBarView: View {
    @EnvironmentObject var gameModel: TetrisGameModel
    let linesForNextLevel = 5
    var body: some View {
        let linesClearedInCurrentLevel = (gameModel.gameLevel.linesCleared % 5)
        HStack {
            // New: Speed indicator
//            Text("(\(gameModel.gameLevel.speedPercentage)% speed)")
//                .font(.caption)
//                .foregroundColor(speedColor())
            Spacer()
            VStack {
                Text(String(gameModel.scoreSystem.highScore))
                    .font(.title3.bold())
                Text("HIGH")
                    .font(.subheadline)
            }
            Spacer()
            VStack {
                Text(String(gameModel.scoreSystem.score))
                    .font(.title3.bold())
                Text("SCORE")
                    .font(.subheadline)
            }
            Spacer()
            VStack(spacing: 10) {
                HStack {
                    Text("LEVEL")
                        .font(.subheadline)
                    Text(String(gameModel.gameLevel.level))
                        .font(.title3.bold())
                }
                
                HStack(spacing: 4) {
                    ForEach(0..<linesForNextLevel, id: \.self) { i in
                        Rectangle()
                            .fill(i < (linesClearedInCurrentLevel) ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)

                    }
                }
            }
            Spacer()
        }
        .padding(.vertical)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal, 10)
    }
}

#Preview {
    ScoreBarView()
        .environmentObject(TetrisGameModel.shared)
}
