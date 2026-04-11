//
//  TetrisGameSessionMigrationPlan.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

import Foundation
import SwiftData

enum NeotrisSchemaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TetrisGameSessionSchemaV1.self, NeotrisV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: TetrisGameSessionSchemaV1.self,
        toVersion: NeotrisV2.self
    )
}
