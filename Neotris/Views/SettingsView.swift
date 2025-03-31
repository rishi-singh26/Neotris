//
//  SettingsView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var gameModel: TetrisGameModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showPrivacyPolicy: Bool = false
    @State private var showTermsOfUse: Bool = false
    @State private var showUsageLicense: Bool = false
    
    let privacyPolicyURL = "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/Assets/PrivacyPolicy.md"
    let termsOfuserURL = "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/Assets/TermsOfUse.md"
    let usageLicenseURL = "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/LICENSE"
    
    var body: some View {
        Group {
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
                    
                    MacCustomSection(footer: "Want to support my work? Star the GitHub repository to show support. Go the Open Source Code and click on the STAR button.") {
                        Button {
                            showPrivacyPolicy = true
                        } label: {
                            CustomLabel(leadingImageName: "bolt.shield", trailingImageName: "chevron.up", title: "Privacy Policy")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.vertical, 2)
                        Button {
                            showTermsOfUse = true
                        } label: {
                            CustomLabel(leadingImageName: "list.bullet.rectangle.portrait", trailingImageName: "chevron.up", title: "Terms of Use")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.vertical, 2)
                        Button {
                            showUsageLicense = true
                        } label: {
                            CustomLabel(leadingImageName: "checkmark.seal", trailingImageName: "chevron.up", title: "Usage License")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.vertical, 2)
                        Link(destination: URL(string: "https://github.com/rishi-singh26/Neotris")!) {
                            CustomLabel(leadingImageName: "lock.open.display", trailingImageName: "arrow.up.right", title: "Open Source Code")
                        }
                    }
                    .padding(.bottom)
                    
                    MacCustomSection {
                        Button {
                            getFeedback()
                        } label: {
                            CustomLabel(leadingImageName: "star", title: "Rate Us")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.vertical, 2)
                        Text("Neotris v.1.0.0")
                    }
                        .padding(.bottom)
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
                        Button {
                            showPrivacyPolicy = true
                        } label: {
                            CustomLabel(leadingImageName: "bolt.shield", trailingImageName: "chevron.up", title: "Privacy Policy")
                        }
                        Button {
                            showTermsOfUse = true
                        } label: {
                            CustomLabel(leadingImageName: "list.bullet.rectangle.portrait", trailingImageName: "chevron.up", title: "Terms of Use")
                        }
                        Button {
                            showUsageLicense = true
                        } label: {
                            CustomLabel(leadingImageName: "checkmark.seal", trailingImageName: "chevron.up", title: "Usage License")
                        }
                        Link(destination: URL(string: "https://github.com/rishi-singh26/i2048")!) {
                            CustomLabel(leadingImageName: "lock.open.display", trailingImageName: "arrow.up.right", title: "Open Source Code")
                        }
                    }
                    .listRowBackground(
                        Rectangle()
                            .fill(.thinMaterial)
                    )
                    
                    Section {
                        Button {
                            getFeedback()
                        } label: {
                            Label("Rate Us", systemImage: "star")
                        }
                        Text("Neotris v.1.0.0")
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
        .sheet(isPresented: $showPrivacyPolicy) {
            BuildSheetView(url: URL(string: privacyPolicyURL), navigationTitle: "Privacy Policy")
        }
        .sheet(isPresented: $showTermsOfUse) {
            BuildSheetView(url: URL(string: termsOfuserURL), navigationTitle: "Terms Of Use")
        }
        .sheet(isPresented: $showUsageLicense) {
            BuildSheetView(url: URL(string: usageLicenseURL), navigationTitle: "Usage License")
        }
    }
    
    @ViewBuilder
    private func BuildSheetView(url: URL?, navigationTitle: String) -> some View {
#if os(macOS)
        MarkdownWebView(url: url!)
            .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
#else
        NavigationView {
            MarkdownWebView(url: url!)
                .navigationTitle(navigationTitle)
        }
            .presentationDetents([.large])
            .presentationBackground(.thinMaterial)
            .presentationCornerRadius(25)
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
    
    private func getFeedback() {
#if os(iOS)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
#elseif os(macOS)
        SKStoreReviewController.requestReview() // macOS doesn't need a scene
#elseif os(tvOS)
        SKStoreReviewController.requestReview() // tvOS doesn't need a scene
#elseif os(watchOS)
        // watchOS doesn't support SKStoreReviewController
        print("SKStoreReviewController not supported on watchOS")
#endif
    }
}

#Preview {
    SettingsView()
        .environmentObject(TetrisGameModel.shared)
}
