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
    let sharedModelContainer: ModelContainer
    
    init() {
        let schema = Schema([
            TetrisGameSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(
                for: schema,
//                migrationPlan: TetrisGameSessionMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TetrisGameView()
                .environmentObject(loadSavedGame())
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .windowStyle(.automatic)
        .windowResizability(.contentSize)
        #endif
    }
    
    func loadSavedGame() -> TetrisGameModel {
        if let savedGame = TetrisGameModel.loadSavedGame(modelContext: sharedModelContainer.mainContext) {
                    savedGame
        } else {
            TetrisGameModel(modelContext: sharedModelContainer.mainContext)
        }
    }
}
