//
//  TetrisGameSessionMigrationPlan.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

import Foundation
import SwiftData

enum TetrisGameSessionMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TetrisGameSessionSchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        []
//        [migrateV1toV2, migrateV2toV3, migrateV3toV4]
    }
    
//    static let migrateV1toV2 = MigrationStage.lightweight(
//        fromVersion: GameSchemaV1.self,
//        toVersion: GameSchemaV2.self
//    )
//    
//    static let migrateV2toV3 = MigrationStage.lightweight(
//        fromVersion: GameSchemaV2.self,
//        toVersion: GameSchemaV3.self
//    )
//    
//    static let migrateV3toV4 = MigrationStage.lightweight(
//        fromVersion: GameSchemaV3.self,
//        toVersion: GameSchemaV4.self
//    )
}
