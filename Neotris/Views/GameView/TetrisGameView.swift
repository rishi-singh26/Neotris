//
//  TetrisGameView.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI

// Main game view
struct TetrisGameView: View {
    @State private var showSettingSheet: Bool = false
    @State private var showInstructionSheet: Bool = false
    @State private var showSessionSheet: Bool = false
    @EnvironmentObject var gameModel: TetrisGameModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAlert: Bool = false
    @AppStorage("headerText") var headerText: String = "Neotris"
    
    var body: some View {
        ZStack {
            // Background
            GameBackgroundView()
            
            if DeviceType.current == .iPhone {
                VStack(spacing: 10) {
                    Text(headerText)
                        .foregroundStyle(.white)
                        .font(.largeTitle.bold())
                        .fontDesign(.monospaced)
                        .gesture(
                            TapGesture(count: 5)
                                .onEnded {
                                    showAlert.toggle()
                                }
                        )
                    
                    ScoreBarView()
                    
                    HStack {
                        GameBoardView(gameModel: gameModel)
                        
                        GameRightView(
                            showSettingsSheet: $showSettingSheet,
                            showInstructionSheet: $showInstructionSheet,
                            showSessionSheet: $showSessionSheet
                        )
                    }
                    .padding(.horizontal, 10)
                    
                    ControlBarView()
                }
            } else {
                VStack(spacing: 50) {
                    Text(headerText)
                        .foregroundStyle(.white)
                        .font(.largeTitle.bold())
                        .fontDesign(.monospaced)
                        .gesture(
                            TapGesture(count: 5)
                                .onEnded {
                                    showAlert.toggle()
                                }
                        )
                    
                    HStack {
                        ScoreBarView()
                        
                        GameBoardView(gameModel: gameModel)
                        
                        GameRightView(
                            showSettingsSheet: $showSettingSheet,
                            showInstructionSheet: $showInstructionSheet,
                            showSessionSheet: $showSessionSheet
                        )
                    }
                    .padding(.horizontal, 10)
                    
                    ControlBarView()
                }            }
            
            // Level up animation overlay
            if gameModel.showLevelUpAnimation {
                LevelUpView()
            }
            
            // Game over overlay
            if gameModel.gameState == .gameOver {
                GameOverView()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    
                    if abs(horizontal) > abs(vertical) {
                        // Horizontal swipe
                        if horizontal > 20 {
                            gameModel.moveRight()
                        } else if horizontal < -20 {
                            gameModel.moveLeft()
                        }
                    } else {
                        // Vertical swipe
                        if vertical > 20 {
                            gameModel.moveDown()
                        } else if vertical < -20 {
                            gameModel.rotate()
                        }
                    }
                }
        )
        .sheet(isPresented: $showSettingSheet) {
            SettingsView()
                .presentationDetents(DeviceType.current == .iPhone ? [.medium, .large]: [.large])
                .presentationBackground(.thinMaterial)
                .presentationCornerRadius(25)
        }
        .sheet(isPresented: $showInstructionSheet) {
            GameInstructionsView()
                .presentationDetents(DeviceType.current == .iPhone ? [.medium, .large]: [.large])
                .presentationBackground(.thinMaterial)
                .presentationCornerRadius(25)
        }
        .sheet(isPresented: $showSessionSheet) {
            GameSessionsListView()
                .presentationDetents(DeviceType.current == .iPhone ? [.medium, .large]: [.large])
                .presentationBackground(.thinMaterial)
                .presentationCornerRadius(25)
        }
#if os(macOS)
        .alert("Header Text", isPresented: $showAlert) {
            TextField("Enter text here", text: $headerText)
            Button("Reset", role: .cancel) {
                headerText = "Neotris"
            }
            Button("Update") {}
        } message: {
            Text("Update header text")
        }
#else
        .alert(isPresented: $showAlert) {
            /// YOUR ALERT CONTENT IN VIEW FORMAT
            CustomDialogTwo(
                title: "Header Text",
                content: "Update header text",
                button1: .init(content: "Update", tint: .blue, foreground: .white, action: { text in
                    headerText = text
                    showAlert = false
                }),
                button2: .init(content: "Reset", tint: .red, foreground: .white, action: { _ in
                    headerText = "Neotris"
                    showAlert = false
                }),
                addsTextField: true,
                textFieldHint: "Neotris"
            )
            // Since it's using "if" condition to add view we can use SwiftUI Transition
            // .transition(.blurReplace.combined(with: .push(from: .bottom)))
            .transition(.scale.combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: gameModel.gameState == .gameOver)
        } background: {
            // YOUR BACKGROUND CONTENT IN VIEW FORMAT
            // Rectangle().fill(.primary.opacity (0.35))
        }
#endif
        .onAppear {
            setupKeyboardControls()
        }
        .environment(\.colorScheme, getColorScheme())
    }
    
    // Setup keyboard controls for iPad/Mac
    private func setupKeyboardControls() {
#if os(macOS)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            //            Logic to resume game with "P" key
            //            if gameModel.gameState == .paused && event.keyCode == 35 {
            //                gameModel.resumeGame()
            //                return nil
            //            }
            guard gameModel.gameState == .playing else { return event }
            
            switch event.keyCode {
            case 123: // Left arrow
                gameModel.moveLeft()
                return nil
            case 124: // Right arrow
                gameModel.moveRight()
                return nil
            case 125: // Down arrow
                gameModel.hardDrop()
                return nil
            case 126: // Up arrow
                gameModel.rotate()
                return nil
            case 49: // Space
                gameModel.rotate()
                return nil
            case 35: // P key (pause)
                gameModel.pauseGame()
                return nil
            default:
                return event
            }
        }
#else
        // No keyboard handling for other devices
#endif
    }
    
    private func getColorScheme() -> ColorScheme {
        switch gameModel.gameTheme {
        case 0:
            return colorScheme
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return colorScheme
        }
    }
}

#Preview {
    TetrisGameView()
        .environmentObject(TetrisGameModel.shared)
}
