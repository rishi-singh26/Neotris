//
//  NeotrisApp.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

import SwiftUI
import SwiftData

@main
struct NeotrisApp: App {
    @Environment(\.openWindow) var openWindow
    let sharedModelContainer: ModelContainer
    @State private var viewModel: GameViewModel

    let gameWidth: CGFloat = 650
    let gameHeight: CGFloat = 790

    init() {
        let schema = Schema([TetrisGameSession.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            sharedModelContainer = container

            if let savedState = PersistenceService.loadSavedGameState() {
                _viewModel = State(wrappedValue: GameViewModel(savedState: savedState, modelContext: container.mainContext))
            } else {
                _viewModel = State(wrappedValue: GameViewModel(modelContext: container.mainContext))
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            TetrisGameView()
                .frame(minWidth: gameWidth, maxWidth: .infinity, minHeight: gameHeight, maxHeight: .infinity)
                .environment(viewModel)
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: gameWidth, height: gameHeight)
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            SidebarCommands()
            CommandMenu("Game") {
                Button("How to play") {
                    openWindow(id: "howtoplay")
                }
                .keyboardShortcut("G", modifiers: [.command])
            }
        }
#endif

#if os(macOS)
        Window("How to play", id: "howtoplay") {
            InstructionsViewBuilder()
                .frame(minWidth: 400, maxWidth: 500, minHeight: 400, maxHeight: 600)
        }
        .defaultSize(width: 400, height: 400)
        .windowResizability(.contentSize)

        Settings {
            SettingsView(isWindow: true)
                .environment(viewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 500, height: 500)
#endif
    }
}
