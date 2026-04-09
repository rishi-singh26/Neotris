//
//  SettingsView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    var isWindow: Bool = false
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.dismiss) var dismiss

    @State private var showPrivacyPolicy: Bool = false
    @State private var showTermsOfUse: Bool = false
    @State private var showUsageLicense: Bool = false

    let privacyPolicyURL = "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/Assets/PrivacyPolicy.md"
    let termsOfuserURL = "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/Assets/TermsOfUse.md"
    let usageLicenseURL = "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/LICENSE"

    var body: some View {
        // @Bindable lets us create $bindings from an @Observable object
        @Bindable var vm = viewModel

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
                            Text("Ghost Blocks")
                                .frame(width: 150, alignment: .leading)
                            Spacer()
                            Toggle("", isOn: $vm.ghostBlocksEnabled.animation())
                                .toggleStyle(.switch)
                        }
                    }

                    MacCustomSection {
                        HStack(alignment: .center) {
                            Text("Game Theme")
                                .frame(width: 150, alignment: .leading)
                            Spacer()
                            Picker("", selection: $vm.gameTheme.animation()) {
                                Label("System", systemImage: "iphone.gen2").tag(0)
                                Label("Light", systemImage: "sun.max").tag(1)
                                Label("Dark", systemImage: "moon.stars").tag(2)
                            }
                        }
                    }

                    MacCustomSection(footer: "Want to support my work? Star the GitHub repository to show support. Go the Open Source Code and click on the STAR button.") {
                        Button { showPrivacyPolicy = true } label: {
                            CustomLabel(leadingImageName: "bolt.shield", trailingImageName: "chevron.up", title: "Privacy Policy")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.vertical, 2)
                        Button { showTermsOfUse = true } label: {
                            CustomLabel(leadingImageName: "list.bullet.rectangle.portrait", trailingImageName: "chevron.up", title: "Terms of Use")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.vertical, 2)
                        Link(destination: URL(string: "https://letterbird.co/neotris")!) {
                            CustomLabel(leadingImageName: "text.bubble", trailingImageName: "arrow.up.right", title: "Help & Support")
                        }
                        Divider().padding(.vertical, 2)
                        Link(destination: URL(string: "https://github.com/rishi-singh26/Neotris")!) {
                            CustomLabel(leadingImageName: "lock.open.display", trailingImageName: "arrow.up.right", title: "Open Source Code")
                        }
                    }
                    .padding(.bottom)

                    MacCustomSection {
                        Button { getFeedback() } label: {
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
            .background(isWindow ? nil : VisualEffectView(material: .popover, blendingMode: .behindWindow))
            .toolbar {
                if !isWindow {
                    Button("Done") { dismiss() }
                }
            }
#else
            NavigationView {
                List {
                    Section {
                        Toggle(isOn: $vm.hapticFeedbackEnabled.animation()) {
                            Label(
                                "Haptic Feedback",
                                systemImage: viewModel.hapticFeedbackEnabled ? "hand.tap.fill" : "hand.tap"
                            )
                        }
                        .toggleStyle(.switch)
                        Toggle(isOn: $vm.ghostBlocksEnabled.animation()) {
                            Label(
                                "Ghost Blocks",
                                systemImage: viewModel.ghostBlocksEnabled ? "inset.filled.square.dashed" : "square.dashed"
                            )
                        }
                    }
                    .listRowBackground(Rectangle().fill(.thinMaterial))

                    Section {
                        Picker(selection: $vm.gameTheme.animation()) {
                            Label("System", systemImage: "iphone.gen2").tag(0)
                            Label("Light", systemImage: "sun.max").tag(1)
                            Label("Dark", systemImage: "moon.stars").tag(2)
                        } label: {
                            Label("Game Theme", systemImage: getColorSchemeIcon())
                        }
                    }
                    .listRowBackground(Rectangle().fill(.thinMaterial))

                    Section {
                        Button { showPrivacyPolicy = true } label: {
                            CustomLabel(leadingImageName: "bolt.shield", trailingImageName: "chevron.up", title: "Privacy Policy")
                        }
                        Button { showTermsOfUse = true } label: {
                            CustomLabel(leadingImageName: "list.bullet.rectangle.portrait", trailingImageName: "chevron.up", title: "Terms of Use")
                        }
                        Link(destination: URL(string: "https://letterbird.co/neotris")!) {
                            CustomLabel(leadingImageName: "text.bubble", trailingImageName: "arrow.up.right", title: "Help & Support")
                        }
                        Link(destination: URL(string: "https://github.com/rishi-singh26/Neotris")!) {
                            CustomLabel(leadingImageName: "lock.open.display", trailingImageName: "arrow.up.right", title: "Open Source Code")
                        }
                    }
                    .listRowBackground(Rectangle().fill(.thinMaterial))

                    Section {
                        Button { getFeedback() } label: {
                            Label("Rate Us", systemImage: "star")
                        }
                        Text("Neotris v.1.0.0")
                    }
                    .listRowBackground(Rectangle().fill(.thinMaterial))
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem {
                        Button { dismiss() } label: {
                            Label("Dismiss", systemImage: "xmark.circle.fill")
                        }
                    }
                }
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
                .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .presentationBackground(.thinMaterial)
        .presentationCornerRadius(25)
#endif
    }

    private func getColorSchemeIcon() -> String {
        switch viewModel.gameTheme {
        case 1:  return "sun.max"
        case 2:  return "moon.stars"
        default: return "iphone.gen2"
        }
    }

    private func getFeedback() {
#if os(iOS)
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
#elseif os(macOS)
        SKStoreReviewController.requestReview()
#endif
    }
}

#Preview {
    SettingsView()
        .environment(GameViewModel())
}
