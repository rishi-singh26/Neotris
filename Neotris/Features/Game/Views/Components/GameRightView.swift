//
//  GameRightView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI
import TipKit

struct GameRightView: View {
    @Environment(GameViewModel.self) private var viewModel
    #if os(macOS)
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow
    #endif
    
    @Binding var showSettingsSheet: Bool
    @Binding var showInstructionSheet: Bool
    @Binding var showSessionSheet: Bool

    private let gameThemesTip = GameThemesTip()
    #if os(macOS)
    private let keyboardShortcutsTip = KeyboardShortcutsTip()
    #endif

    var body: some View {
        VStack {
            VStack {
                NextPieceView(tetromino: viewModel.nextTetromino)
                NextPieceView(tetromino: viewModel.secondNextTetromino)
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .cornerRadius(20)

            VStack {
                ControlButton(iconName: "questionmark.circle.fill") {
                    viewModel.pauseGame()
                    #if os(macOS)
                    openWindow(id: "howtoplay")
                    #else
                    showInstructionSheet = true
                    #endif
                }
                ControlButton(iconName: "list.dash") {
                    viewModel.pauseGame()
                    #if os(macOS)
                    openWindow(id: "gamesessions")
                    #else
                    showSessionSheet = true
                    #endif
                }
                ControlButton(iconName: "switch.2") {
                    viewModel.pauseGame()
                    #if os(macOS)
                    openSettings()
                    #else
                    showSettingsSheet = true
                    #endif
                }
                .popoverTip(gameThemesTip, arrowEdge: .leading)
                #if os(macOS)
                .popoverTip(keyboardShortcutsTip, arrowEdge: .leading)
                #endif
                .task {
                    for await status in gameThemesTip.statusUpdates {
                        if case .invalidated = status {
                            GameThemesTip.isDismissed = true
                        }
                    }
                }
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
    }
}

#Preview {
    GameRightView(
        showSettingsSheet: .constant(false),
        showInstructionSheet: .constant(false),
        showSessionSheet: .constant(false)
    )
    .environment(GameViewModel())
}
