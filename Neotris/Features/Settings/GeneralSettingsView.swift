//
//  GeneralSettingsView.swift
//  Neotris
//
//  Created by Rishi Singh on 10/04/26.
//

#if os(macOS)
import SwiftUI
import StoreKit

struct GeneralSettingsView: View {
    @Environment(GameViewModel.self) private var viewModel
    
    @State private var showPrivacyPolicy: Bool = false
    @State private var showTermsOfUse: Bool = false
    
    var body: some View {
        // @Bindable lets us create $bindings from an @Observable object
        @Bindable var vm = viewModel
        
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

            MacCustomSection {
                Link(destination: URL(string: "https://letterbird.co/neotris")!) {
                    CustomLabel(leadingImageName: "text.bubble", trailingImageName: "arrow.up.right", title: "Help & Support")
                }
                Divider().padding(.vertical, 2)
                Link(destination: URL(string: "https://github.com/rishi-singh26/Neotris")!) {
                    CustomLabel(leadingImageName: "lock.open.display", trailingImageName: "arrow.up.right", title: "Open Source Code")
                }
            }
            MacCustomSection {
                Button { getFeedback() } label: {
                    CustomLabel(leadingImageName: "star", title: "Rate Us")
                }
                .buttonStyle(PlainButtonStyle())
                Divider().padding(.vertical, 2)
                Text("Neotris v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
            }
            .padding(.bottom)
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
    GeneralSettingsView()
        .environment(GameViewModel())
}
#endif
