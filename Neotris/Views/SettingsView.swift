//
//  SettingsView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameModel: TetrisGameModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $gameModel.hapticFeedbackEnabled.animation()) {
                        Label("Haptic Feedback", systemImage: gameModel.hapticFeedbackEnabled ? "hand.tap.fill" : "hand.tap")
                    }
                    .toggleStyle(.switch)
                    Toggle(isOn: $gameModel.gameSoundEnabled.animation()) {
                        Label(
                            "Game Sound",
                            systemImage: gameModel.gameSoundEnabled ? "speaker.wave.3.fill" : "speaker.wave.3"
                        )
                    }
                    .toggleStyle(.switch)
                    Toggle(isOn: $gameModel.ghostBlocksEnabled.animation().animation()) {
                        Label(
                            "Ghost Blocks",
                            systemImage: gameModel.ghostBlocksEnabled ? "inset.filled.square.dashed" : "square.dashed"
                        )
                    }
                }
                .listRowBackground(
                    Rectangle()
                        .fill(.thinMaterial)
                )
                
                Section {
                    Picker(selection: $gameModel.gameTheme.animation()) {
                        Label("System", systemImage: "iphone.gen2")
                            .tag(0)
                        Label("Light", systemImage: "sun.max")
                            .tag(1)
                        Label("Dark", systemImage: "moon.stars")
                            .tag(2)
                    } label: {
                        Label("Game Theme", systemImage: getColorSchemeIcon())
                    }
//                    .pickerStyle(.navigationLink)
                }
                .listRowBackground(
                    Rectangle()
                        .fill(.thinMaterial)
                )
                
                Section {
                    Label("Games List", systemImage: "list.dash")
                }
                .listRowBackground(
                    Rectangle()
                        .fill(.thinMaterial)
                )
            }
            .scrollContentBackground(.hidden)
//                    .background(Color.mint)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label("Dismiss", systemImage: "xmark.circle.fill")
                    }

                }
            })
        }
    }
    
    private func getColorSchemeIcon() -> String {
        switch gameModel.gameTheme {
        case 0:
            return "iphone.gen2"
        case 1:
            return "sun.max"
        case 2:
            return "moon.stars"
        default:
            return "iphone.gen2"
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(TetrisGameModel.shared)
}
