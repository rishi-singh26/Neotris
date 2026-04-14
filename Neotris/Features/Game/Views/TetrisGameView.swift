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
#if os(macOS)
    @State private var keyEventMonitor: Any?
#endif

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
#if os(macOS)
        .onDisappear {
            tearDownKeyboardControls()
        }
#endif
    }

    private func setupKeyboardControls() {
#if os(macOS)
        guard keyEventMonitor == nil else { return }
        keyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if viewModel.gameState == .paused && self.matches(event, .resume) {
                viewModel.resumeGame()
                return nil
            }
            guard viewModel.gameState == .playing else { return event }
            if self.matches(event, .moveLeft)  { viewModel.moveLeft();  return nil }
            if self.matches(event, .moveRight) { viewModel.moveRight(); return nil }
            if self.matches(event, .hardDrop)  { viewModel.hardDrop();  return nil }
            if self.matches(event, .rotate)    { viewModel.rotate();    return nil }
            if self.matches(event, .pause)     { viewModel.pauseGame(); return nil }
            return event
        }
#endif
    }

#if os(macOS)
    private func tearDownKeyboardControls() {
        if let monitor = keyEventMonitor {
            NSEvent.removeMonitor(monitor)
            keyEventMonitor = nil
        }
    }

    private func matches(_ event: NSEvent, _ action: GameAction) -> Bool {
        let eventMods = event.modifierFlags.intersection(KeyBinding.userModifierMask).rawValue
        return viewModel.bindings(for: action).contains { binding in
            event.keyCode == binding.keyCode && eventMods == binding.modifierFlags
        }
    }
#endif

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
