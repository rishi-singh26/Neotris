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
    // Create a single shared instance of your game model
    @StateObject private var gameModel: TetrisGameModel
    
    init() {
        let schema = Schema([
            TetrisGameSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            sharedModelContainer = container
            
            // Now initialize gameModel using the created container
            let model: TetrisGameModel
            if let savedGame = TetrisGameModel.loadSavedGame(modelContext: container.mainContext) {
                model = savedGame
            } else {
                model = TetrisGameModel(modelContext: container.mainContext)
            }
            
            // Initialize the StateObject with the model
            _gameModel = StateObject(wrappedValue: model)
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TetrisGameView()
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 900, maxHeight: .infinity)
                .environmentObject(gameModel)
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 800, height: 900)
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
                .environmentObject(gameModel)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 500, height: 500)
        #endif
    }
}
