//
//  HeaderTextView.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI

struct HeaderTextView: View {
    private let defaultHeaderText = "Neotris"
    private let maxHeaderTextLength = 12

    @State private var showAlert: Bool = false
    @AppStorage("headerText") private var headerText: String = "Neotris"
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        Text(sanitizedHeaderText(headerText))
            .foregroundStyle(.white)
            .font(.largeTitle.bold())
            .fontDesign(.monospaced)
            .gesture(
                TapGesture(count: 2)
                    .onEnded { showAlert.toggle() }
            )
#if os(macOS)
            .alert("Header Text", isPresented: $showAlert) {
                TextField(
                    "Enter text here",
                    text: Binding(
                        get: { headerText },
                        set: { headerText = String($0.prefix(maxHeaderTextLength)) }
                    )
                )
                Button("Reset", role: .cancel) { headerText = defaultHeaderText }
                Button("Update") {
                    headerText = sanitizedHeaderText(headerText)
                }
            } message: {
                Text("Update header text")
            }
#else
            .alert(isPresented: $showAlert) {
                CustomDialogTwo(
                    title: "Header Text",
                    content: "Update header text",
                    button1: .init(content: "Update", tint: .blue, foreground: .white, action: { text in
                        headerText = sanitizedHeaderText(text)
                        showAlert = false
                    }),
                    button2: .init(content: "Reset", tint: .red, foreground: .white, action: { _ in
                        headerText = defaultHeaderText
                        showAlert = false
                    }),
                    addsTextField: true,
                    textFieldHint: "Neotris"
                )
                .transition(.scale.combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: viewModel.gameState == .gameOver)
            } background: {}
#endif
            .onAppear {
                headerText = sanitizedHeaderText(headerText)
            }
    }

    private func sanitizedHeaderText(_ text: String) -> String {
        let limitedText = String(text.prefix(maxHeaderTextLength))
        return limitedText.isEmpty ? defaultHeaderText : limitedText
    }
}

#Preview {
    HeaderTextView()
        .environment(GameViewModel())
}
