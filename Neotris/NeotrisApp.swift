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
        let schema = Schema([TetrisGameSession.self, GameTheme.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, migrationPlan: NeotrisSchemaMigrationPlan.self, configurations: [modelConfiguration])
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
            AppUpdateCheckView()
                .frame(minWidth: gameWidth, maxWidth: .infinity, minHeight: gameHeight, maxHeight: .infinity)
                .environment(viewModel)
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: gameWidth, height: gameHeight)
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
#endif

#if os(macOS)
        Window("How to play", id: "howtoplay") {
            InstructionsViewBuilder()
                .frame(minWidth: 400, maxWidth: 500, minHeight: 400, maxHeight: 600)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 400, height: 400)
        .windowResizability(.contentSize)
        
        Window("Game Sessions", id: "gamesessions") {
            GameSessionsListView()
                .environment(viewModel)
                .frame(minWidth: 400, maxWidth: 500, minHeight: 400, maxHeight: 600)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 400, height: 400)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environment(viewModel)
        }
        .defaultSize(width: 700, height: 400)
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)
#endif
    }
}
