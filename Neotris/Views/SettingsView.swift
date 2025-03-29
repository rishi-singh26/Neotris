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
                    Toggle(isOn: $gameModel.hapticFeedbackEnabled) {
                        Label("Haptic Feedback", systemImage: "hand.tap")
                    }
                    .toggleStyle(.switch)
                    Toggle(isOn: $gameModel.gameSoundEnabled) {
                        Label("Game Sound", systemImage: "speaker.wave.3")
                    }
                    .toggleStyle(.switch)
                    Toggle(isOn: $gameModel.ghostBlocksEnabled) {
                        Label("Ghost Blocks", systemImage: "square.dashed")
                    }
                }
                
                Section {
                    Label("Game History", systemImage: "fossil.shell")
                }
            }
            .scrollContentBackground(.hidden)
            //        .background(Color.mint)
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
}

#Preview {
    SettingsView()
        .environmentObject(TetrisGameModel.shared)
}
