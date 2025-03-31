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
    
    @State private var showPrivacyPolicy: Bool = false
    @State private var showTermsOfUse: Bool = false
    @State private var showUsageLicense: Bool = false
    
    var body: some View {
#if os(macOS)
        VStack {
            HStack {
                Text("Settings")
                    .font(.largeTitle)
                Spacer()
            }
            .padding([.horizontal, .top], 30)
            .padding(.bottom, -1)
            ScrollView {
                MacCustomSection {
                    HStack(alignment: .center) {
                        Text("Haptic Feedback")
                            .frame(width: 150, alignment: .leading)
                        Spacer()
                        Toggle("", isOn: $gameModel.hapticFeedbackEnabled.animation())
                            .toggleStyle(.switch)
                    }
                    Divider()
//                    HStack(alignment: .center) {
//                        Text("Game Sound")
//                            .frame(width: 150, alignment: .leading)
//                        Spacer()
//                        Toggle("", isOn: $gameModel.gameSoundEnabled.animation())
//                            .toggleStyle(.switch)
//                    }
//                    Divider()
                    HStack(alignment: .center) {
                        Text("Ghost Blocks")
                            .frame(width: 150, alignment: .leading)
                        Spacer()
                        Toggle("", isOn: $gameModel.ghostBlocksEnabled.animation())
                            .toggleStyle(.switch)
                    }
                }
                
                MacCustomSection {
                    HStack(alignment: .center) {
                        Text("Game Theme")
                            .frame(width: 150, alignment: .leading)
                        Spacer()
                        Picker("", selection: $gameModel.gameTheme.animation()) {
                            Label("System", systemImage: "iphone.gen2")
                                .tag(0)
                            Label("Light", systemImage: "sun.max")
                                .tag(1)
                            Label("Dark", systemImage: "moon.stars")
                                .tag(2)
                        }
                    }
                }
                
                MacCustomSection {
                    CustomLabel(trailingImageName: "chevron.right", title: "Games Sessions")
                }
            }
            .padding(.bottom)
        }
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
        .toolbar {
            Button("Done") {
                dismiss()
            }
        }
#else
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $gameModel.hapticFeedbackEnabled.animation()) {
                        Label("Haptic Feedback", systemImage: gameModel.hapticFeedbackEnabled ? "hand.tap.fill" : "hand.tap")
                    }
                    .toggleStyle(.switch)
//                    Toggle(isOn: $gameModel.gameSoundEnabled.animation()) {
//                        Label(
//                            "Game Sound",
//                            systemImage: gameModel.gameSoundEnabled ? "speaker.wave.3.fill" : "speaker.wave.3"
//                        )
//                    }
//                    .toggleStyle(.switch)
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
                    Label("Privacy Policy", systemImage: "bolt.shield")
                    Label("Terms of Use", systemImage: "list.bullet.rectangle.portrait")
                    Label("Usage License", systemImage: "checkmark.seal")
                    Link(destination: URL(string: "https://github.com/rishi-singh26/i2048")!) {
                        CustomLabel(leadingImageName: "lock.open.display", trailingImageName: "arrow.up.right", title: "Open Source Code")
                    }
                }
                .listRowBackground(
                    Rectangle()
                        .fill(.thinMaterial)
                )
            }
            .scrollContentBackground(.hidden)
//                    .background(Color.mint)
            .navigationTitle("Settings")
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
#endif
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
