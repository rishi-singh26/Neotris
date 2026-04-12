//
//  TetrisGameView.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI

struct TetrisGameView: View {
    @State private var showSettingSheet: Bool = false
    @State private var showInstructionSheet: Bool = false
    @State private var showSessionSheet: Bool = false
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            GameBackgroundView()

            VStack(spacing: 10) {
                HeaderTextView()

                if DeviceType.current == .iPhone {
                    ScoreBarView()

                    HStack {
                        GameBoardView()
                        GameRightView(
                            showSettingsSheet: $showSettingSheet,
                            showInstructionSheet: $showInstructionSheet,
                            showSessionSheet: $showSessionSheet
                        )
                    }
                    .padding(.horizontal, 10)

                    ControlBarView()
                } else {
                    HStack {
                        ScoreBarView()
                        GameBoardView()
                        GameRightView(
                            showSettingsSheet: $showSettingSheet,
                            showInstructionSheet: $showInstructionSheet,
                            showSessionSheet: $showSessionSheet
                        )
                    }
                    .padding(.horizontal, 10)

                    ControlBarView()
                }
            }

            if viewModel.showLevelUpAnimation {
                VStack {
                    LevelUpView()
                        .padding(.top, 65)
                    Spacer()
                }
            }

            if viewModel.gameState == .gameOver {
                GameOverView()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    if abs(horizontal) > abs(vertical) {
                        if horizontal > 20 { viewModel.moveRight() }
                        else if horizontal < -20 { viewModel.moveLeft() }
                    } else {
                        if vertical > 20 { viewModel.moveDown() }
                        else if vertical < -20 { viewModel.rotate() }
                    }
                }
        )
        .environment(\.colorScheme, getColorScheme())
        .sheet(isPresented: $showSettingSheet) {
            SettingsView()
                .presentationDetents(DeviceType.current == .iPhone ? [.medium, .large] : [.large])
        }
        .sheet(isPresented: $showInstructionSheet) {
            GameInstructionsView()
                .presentationDetents(DeviceType.current == .iPhone ? [.medium, .large] : [.large])
        }
        .sheet(isPresented: $showSessionSheet) {
            GameSessionsListView()
                .presentationDetents(DeviceType.current == .iPhone ? [.medium, .large] : [.large])
        }
        .onAppear {
            setupKeyboardControls()
            viewModel.prepareHapticsIfEnabled()
        }
    }

    private func setupKeyboardControls() {
#if os(macOS)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if viewModel.gameState == .paused && event.keyCode == 15 {
                viewModel.resumeGame()
                return nil
            }
            guard viewModel.gameState == .playing else { return event }
            switch event.keyCode {
            case 123: viewModel.moveLeft();  return nil
            case 124: viewModel.moveRight(); return nil
            case 125: viewModel.hardDrop();  return nil
            case 126: viewModel.rotate();    return nil
            case 49:  viewModel.rotate();    return nil
            case 35:  viewModel.pauseGame(); return nil
            default: return event
            }
        }
#endif
    }

    private func getColorScheme() -> ColorScheme {
        switch viewModel.gameTheme {
        case 1: return .light
        case 2: return .dark
        default: return colorScheme
        }
    }
}

#Preview {
    TetrisGameView()
        .environment(GameViewModel())
}
