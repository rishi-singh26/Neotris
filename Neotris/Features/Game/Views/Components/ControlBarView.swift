//
//  ControlBarView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct ControlBarView: View {
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        HStack {
            if viewModel.gameState == .playing {
                ControlButton(iconName: "chevron.left") { viewModel.moveLeft() }
                Spacer()
                ControlButton(iconName: "arrow.down.to.line.compact") { viewModel.hardDrop() }
            }
            Spacer()

            Button(action: {
                switch viewModel.gameState {
                case .waiting:  viewModel.startGame()
                case .gameOver: viewModel.resetGame(); viewModel.startGame()
                case .playing:  viewModel.pauseGame()
                case .paused:   viewModel.resumeGame()
                }
            }) {
                HStack(spacing: viewModel.gameState == .playing ? 0 : 15) {
                    Image(systemName: buttonIcon)
                    if viewModel.gameState != .playing {
                        Text(buttonText)
                    }
                }
                .padding(.horizontal, 30)
                .frame(width: viewModel.gameState == .playing ? 65 : nil, height: 65)
                .background(.thinMaterial)
                .font(.title2.bold())
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
            if viewModel.gameState == .playing {
                ControlButton(iconName: "arrow.trianglehead.counterclockwise.rotate.90") { viewModel.rotate() }
                Spacer()
                ControlButton(iconName: "chevron.right") { viewModel.moveRight() }
            }
        }
        .padding(10)
        .frame(maxWidth: UIService.screenWidth - 10)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal, DeviceType.current == .iPhone ? 10 : 100)
    }

    private var buttonIcon: String {
        switch viewModel.gameState {
        case .waiting:  return "play.fill"
        case .playing:  return "pause.fill"
        case .paused:   return "play.fill"
        case .gameOver: return "plus.circle.fill"
        }
    }

    private var buttonText: String {
        switch viewModel.gameState {
        case .waiting:  return "Start"
        case .playing:  return ""
        case .paused:   return "Resume"
        case .gameOver: return "Start New Game"
        }
    }
}

#Preview {
    TetrisGameView()
        .environment(GameViewModel())
}
