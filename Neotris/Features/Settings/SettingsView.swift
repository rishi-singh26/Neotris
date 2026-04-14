//
//  SettingsView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI
import StoreKit
//#if os(macOS)
//import AppKit
//#endif

enum SettingPage {
    case generalPage
    case themesPage
    case controlsPage
    case privacyPolicy
    case termsOfUse
}

struct SettingsView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showUsageLicense: Bool = false
    @State private var selectedSettingPage: SettingPage = .generalPage
    
    let privacyPolicyURL = "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/Assets/PrivacyPolicy.md"
    let termsOfuserURL = "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/Assets/TermsOfUse.md"
    let usageLicenseURL = "https://raw.githubusercontent.com/rishi-singh26/Neotris/refs/heads/main/LICENSE"
    
    var body: some View {
        // @Bindable lets us create $bindings from an @Observable object
#if os(macOS)
        MacOSSettings()
#elseif os(iOS)
        IOSSettings()
#endif
    }
    
#if os(macOS)
    @ViewBuilder
    private func MacOSSettings() -> some View {
        NavigationSplitView {
            NavigationListBuilder()
                .navigationTitle("Settings")
                .padding(.top, 10)
        } detail: {
            switch selectedSettingPage {
            case .generalPage:
                GeneralSettingsView()
                    .navigationTitle("General Settings")
            case .themesPage:
                ThemesListView()
                    .navigationTitle("Game Themes")
            case .controlsPage:
                ControlsSettingsView()
                    .navigationTitle("Controls")
            case .privacyPolicy:
                MarkdownWebView(url: URL(string: privacyPolicyURL)!)
                    .navigationTitle("Privacy Policy")
            case .termsOfUse:
                MarkdownWebView(url: URL(string: termsOfuserURL)!)
                    .navigationTitle("Terms of Use")
            }
        }
        .frame(minWidth: 700, minHeight: 400, maxHeight: 700)
        .background(WindowToolbarConfigurator())
    }
    
    @ViewBuilder
    private func NavigationListBuilder() -> some View {
        List(selection: $selectedSettingPage) {
            NavigationLink(value: SettingPage.generalPage) {
                Label("General", systemImage: "gear")
            }
            NavigationLink(value: SettingPage.themesPage) {
                Label("Game Themes", systemImage: "paintpalette")
            }
            NavigationLink(value: SettingPage.controlsPage) {
                Label("Controls", systemImage: "keyboard")
            }
            NavigationLink(value: SettingPage.privacyPolicy) {
                Label("Privacy Policy", systemImage: "lock.open.display")
            }
            NavigationLink(value: SettingPage.termsOfUse) {
                Label("Terms of Use", systemImage: "list.bullet.rectangle.portrait")
            }
        }
        //.listStyle(.sidebar)
        .navigationTitle("Settings")
        .navigationSplitViewColumnWidth(min: 170, ideal: 190, max: 280)
    }
#elseif os(iOS)
    @ViewBuilder
    private func IOSSettings() -> some View {
        @Bindable var vm = viewModel
        
        NavigationStack {
            List {
                Section {
                    Toggle("Ghost Blocks", isOn: $vm.ghostBlocksEnabled.animation())
                        .toggleStyle(.switch)
                    Toggle("Haptic Feedback", isOn: $vm.hapticFeedbackEnabled.animation())
                        .toggleStyle(.switch)
                }
                
                Section {
                    Picker(selection: $vm.gameTheme.animation()) {
                        Label("System", systemImage: "iphone.gen2").tag(0)
                        Label("Light", systemImage: "sun.max").tag(1)
                        Label("Dark", systemImage: "moon.stars").tag(2)
                    } label: {
                        Label {
                            Text("Game Appearance")
                        } icon: {
                            ZStack {
                                Image(systemName: "circle.lefthalf.filled")
                                    .scaleEffect(1.2)
                                Image(systemName: "circle.lefthalf.filled")
                                    .foregroundStyle(.background)
                                    .scaleEffect(0.6)
                                Image(systemName: "circle.righthalf.filled")
                                    .scaleEffect(0.6)
                            }
                        }

                    }
                }
                
                NavigationLink {
                    ThemesListView()
                } label: {
                    Label("Game Themes", systemImage: "paintpalette")
                }
                NavigationLink {
                    MarkdownWebView(url: URL(string: privacyPolicyURL)!)
                } label: {
                    Label("Privacy Policy", systemImage: "lock.open.display")
                }
                NavigationLink {
                    MarkdownWebView(url: URL(string: termsOfuserURL)!)
                } label: {
                    Label("Terms of Use", systemImage: "list.bullet.rectangle.portrait")
                }
                
                Link(destination: URL(string: "https://letterbird.co/neotris")!) {
                    CustomLabel(leadingImageName: "text.bubble", trailingImageName: "arrow.up.right", title: "Help & Support")
                }
                
                Section {
                    Link(destination: URL(string: "https://github.com/rishi-singh26/Neotris")!) {
                        CustomLabel(leadingImageName: "lock.open.display", trailingImageName: "arrow.up.right", title: "Open Source Code")
                    }
                    Button { getFeedback() } label: {
                        Label("Rate Us", systemImage: "star")
                    }
                    Text("Neotris v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                }
            }
            .navigationTitle("Settings")
            .navigationSplitViewColumnWidth(min: 170, ideal: 190, max: 280)
        }
    }
#endif
    
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

#if os(macOS)
private struct WindowToolbarConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.toolbarStyle = .unifiedCompact
            window.titlebarAppearsTransparent = true
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif

#Preview {
    SettingsView()
        .environment(GameViewModel())
        .environment(RemoteDataService())
}
