//
//  LevelUpView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct LevelUpView: View {
    @EnvironmentObject var gameModel: TetrisGameModel
    
    var body: some View {
        VStack {
            Text("LEVEL UP!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
            
            Text("Level \(gameModel.gameLevel.level)")
                .font(.title)
            
            if gameModel.gameLevel.level > 1 {
                Text("Speed: \(gameModel.gameLevel.speedPercentage)%")
                    .font(.headline)
                    .foregroundColor(speedColor())
                    .padding(.top, 8)
            }
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: gameModel.showLevelUpAnimation)
        .environment(\.colorScheme, .dark)
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
    LevelUpView()
        .environmentObject(TetrisGameModel.shared)
}
