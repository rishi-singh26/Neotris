//
//  CustomAlert.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func alert<Content: View, Background: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content, @ViewBuilder background: @escaping () -> Background) -> some View {
        self
            .modifier(CustomAlertModifier(isPresented: isPresented, alertContent: content, background: background))
    }
}

// MARK: - Helper Functions

fileprivate struct CustomAlertModifier<AlertContent: View, Background: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder var alertContent: AlertContent
    @ViewBuilder var background: Background
    // View Properties
    @State private var showFullScreenCover: Bool = false
    @State private var animatedValue: Bool = false
    @State private var allowsInteraction: Bool = false
    
    func body(content: Content) -> some View {
        content
        // Using Full Screen Cover to show alert content on top of the current context
#if os(iOS)
            .fullScreenCover(isPresented: $showFullScreenCover) {
                ZStack {
                    if animatedValue {
                        alertContent
                            .allowsHitTesting(allowsInteraction)
                    }
                }
                .presentationBackground {
                    background
                        .allowsHitTesting(allowsInteraction)
                        .opacity(animatedValue ? 1 : 0)
                }
                .task {
                    try? await Task.sleep(for: .seconds(0.05))
                    withAnimation(.easeInOut(duration: 0.3)) {
                        animatedValue = true
                    }
                    
                    try? await Task.sleep(for: .seconds(0.3))
                    allowsInteraction = true
                }
            }
#endif
            .onChange(of: isPresented) { oldValue, newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                
                if newValue {
                    withTransaction(transaction) {
                        showFullScreenCover = true
                    }
                } else {
                    allowsInteraction = false
                    withAnimation(.easeInOut(duration: 0.3), completionCriteria: .removed) {
                        animatedValue = false
                    } completion: {
                        // Removing full-screen cover without animation
                        withTransaction(transaction) {
                            showFullScreenCover = false
                        }
                    }
                }
            }
    }
}

struct CustomDialog: View {
    var title: String
    var content: String?
    var image: Config
    var button1: Config
    var button2: Config?
    var addsTextField: Bool = false
    var textFieldHint: String = ""
    // State Properties
    @State private var text: String = ""
    
    var body: some View {
        VStack(spacing: 15) {
            Image (systemName: image.content)
                .font(.title)
                .foregroundStyle (image.foreground)
                .frame(width: 65, height: 65)
                .background(image.tint.gradient, in: .circle)
                .background {
                    Circle()
                        .stroke(.background, lineWidth: 8)
                }
            
            Text (title)
                .font(.title3.bold())
            
            if let content {
                Text (content)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .lineLimit (2)
                    .foregroundStyle(.gray)
                    .padding(.vertical, 4)
            }
            
            if addsTextField {
                TextField(textFieldHint, text: $text)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray.opacity(0.1))
                    )
                    .padding(.bottom, 5)
            }
            
            ButtonView(button1)
            
            if let button2 {
                ButtonView(button2)
                    .padding(.top, -5)
            }
        }
        .padding([.horizontal, .bottom], 15)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
                .padding(.top, 30)
        }
        .frame(maxWidth: 310)
        .compositingGroup()
    }
    
    // Button View
    @ViewBuilder
    private func ButtonView(_ config: Config) -> some View {
        Button {
            config.action(addsTextField ? text : "")
        } label: {
            Text(config.content)
                .fontWeight(.bold)
                .foregroundStyle(config.foreground)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(config.tint.gradient, in: .rect(cornerRadius: 10))
        }

    }
    
    struct Config {
        var content: String
        var tint: Color
        var foreground: Color
        var action: (String) -> () = { _ in }
    }
}

struct CustomDialogTwo: View {
    var title: String
    var content: String?
    var button1: Config
    var button2: Config?
    var addsTextField: Bool = false
    var textFieldHint: String = ""
    // State Properties
    @State private var text: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle.bold())
                .padding(.bottom, -1)
                .padding(.leading, 10)
            
            if let content {
                Text(content)
                    .padding(.horizontal, 10)
            }
            
            if addsTextField {
                TextField(textFieldHint, text: $text)
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.secondary)
                    )
                    .padding(.bottom, 5)
            }
            
            HStack {
                if let button2 {
                    ButtonView(button2)
                    Spacer()
                }
                
                ButtonView(button1)
            }
        }
        .frame(minWidth: 345, maxWidth: 345)
        .padding([.horizontal, .bottom], 20)
        .padding(.top, 20)
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .padding(10)
    }
    
    
    // Button View
    @ViewBuilder
    private func ButtonView(_ config: Config) -> some View {
        Button(action: {
            config.action(addsTextField ? text : "")
        }) {
            HStack {
                Spacer()
                Text(config.content)
                Spacer()
            }
                .frame(height: 55)
                .background(.thinMaterial)
                .font((config.role == .destructive || config.role == .cancel) ? .title3.bold() : .title3)
                .foregroundStyle(config.role == .destructive ? .red : Color.primary)
                .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())

    }
    
    struct Config {
        var content: String
        var tint: Color
        var foreground: Color
        var role: ButtonRole?
        var action: (String) -> () = { _ in }
    }
}

#Preview {
    TetrisGameView()
        .environmentObject(TetrisGameModel.shared)
}
