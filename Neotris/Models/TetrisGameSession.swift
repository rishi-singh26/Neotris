//
//  TetrisGameSession.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

import Foundation
import SwiftData


enum TetrisGameSessionSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [TetrisGameSession.self]
    }
    // Game session data for SwiftData storage
    @Model
    class TetrisGameSession {
        var creationDate: Date = Date()
        var completionDate: Date = Date()
        var score: Int = 0
        var level: Int = 1
        var linesCleared: Int = 0
        var playDuration: TimeInterval = 0.0
        
        init(creationDate: Date = Date(), completionDate: Date = Date(), score: Int = 0, level: Int = 1, linesCleared: Int = 0, playDuration: TimeInterval = 0.0) {
            self.creationDate = creationDate
            self.completionDate = completionDate
            self.score = score
            self.level = level
            self.linesCleared = linesCleared
            self.playDuration = playDuration
        }
    }
}

typealias TetrisGameSession = TetrisGameSessionSchemaV1.TetrisGameSession
