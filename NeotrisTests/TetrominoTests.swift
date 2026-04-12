//
//  TetrominoTests.swift
//  NeotrisTests
//

import Testing
import Foundation
@testable import Neotris

struct TetrominoTests {

    // MARK: - Initialization

    @Test func initSetsTypeAndPosition() {
        let tetromino = Tetromino(type: .i, startPosition: (x: 4, y: 0))
        #expect(tetromino.type == .i)
        #expect(tetromino.position.x == 4)
        #expect(tetromino.position.y == 0)
    }

    @Test func initCopiesBlocksFromType() {
        let tetromino = Tetromino(type: .i, startPosition: (x: 0, y: 0))
        #expect(tetromino.blocks == TetrominoType.i.blocks)
    }

    @Test func initialRotationIsZero() {
        let tetromino = Tetromino(type: .t, startPosition: (x: 0, y: 0))
        #expect(tetromino.rotation == 0)
    }

    // MARK: - Absolute Block Positions

    @Test func absolutePositionsAddOffset() {
        // I piece: relative blocks (0,0),(1,0),(2,0),(3,0). Position (3,5).
        let tetromino = Tetromino(type: .i, startPosition: (x: 3, y: 5))
        let abs = tetromino.absoluteBlockPositions()
        let expected: Set<Block> = [Block(x: 3, y: 5), Block(x: 4, y: 5), Block(x: 5, y: 5), Block(x: 6, y: 5)]
        #expect(Set(abs) == expected)
    }

    @Test func absolutePositionsAtOrigin() {
        let tetromino = Tetromino(type: .o, startPosition: (x: 0, y: 0))
        let abs = tetromino.absoluteBlockPositions()
        let expected: Set<Block> = [Block(x: 0, y: 0), Block(x: 1, y: 0), Block(x: 0, y: 1), Block(x: 1, y: 1)]
        #expect(Set(abs) == expected)
    }

    @Test func absolutePositionsReflectCurrentPosition() {
        var tetromino = Tetromino(type: .o, startPosition: (x: 0, y: 0))
        tetromino.position = (x: 5, y: 8)
        let abs = tetromino.absoluteBlockPositions()
        let expected: Set<Block> = [Block(x: 5, y: 8), Block(x: 6, y: 8), Block(x: 5, y: 9), Block(x: 6, y: 9)]
        #expect(Set(abs) == expected)
    }

    @Test func absolutePositionsCountMatchesBlockCount() {
        let tetromino = Tetromino(type: .t, startPosition: (x: 4, y: 0))
        #expect(tetromino.absoluteBlockPositions().count == tetromino.blocks.count)
    }

    // MARK: - O-Piece Rotation (no-op)

    @Test func oPieceRotateIsNoOp() {
        var tetromino = Tetromino(type: .o, startPosition: (x: 0, y: 0))
        let originalBlocks = tetromino.blocks
        tetromino.rotate()
        #expect(tetromino.blocks == originalBlocks)
    }

    @Test func oPieceRotationStateStaysZero() {
        var tetromino = Tetromino(type: .o, startPosition: (x: 0, y: 0))
        tetromino.rotate()
        tetromino.rotate()
        #expect(tetromino.rotation == 0)
    }

    // MARK: - Clockwise Rotation State

    @Test func clockwiseRotationCyclesState() {
        var tetromino = Tetromino(type: .t, startPosition: (x: 0, y: 0))
        tetromino.rotate(clockwise: true)
        #expect(tetromino.rotation == 1)
        tetromino.rotate(clockwise: true)
        #expect(tetromino.rotation == 2)
        tetromino.rotate(clockwise: true)
        #expect(tetromino.rotation == 3)
        tetromino.rotate(clockwise: true)
        #expect(tetromino.rotation == 0)
    }

    @Test func counterClockwiseRotationCyclesStateBackward() {
        var tetromino = Tetromino(type: .t, startPosition: (x: 0, y: 0))
        tetromino.rotate(clockwise: false)
        #expect(tetromino.rotation == 3)
        tetromino.rotate(clockwise: false)
        #expect(tetromino.rotation == 2)
        tetromino.rotate(clockwise: false)
        #expect(tetromino.rotation == 1)
        tetromino.rotate(clockwise: false)
        #expect(tetromino.rotation == 0)
    }

    // MARK: - Rotation Identity

    @Test func fourClockwiseRotationsRestoreBlocks() {
        for type in TetrominoType.allCases {
            var tetromino = Tetromino(type: type, startPosition: (x: 0, y: 0))
            let original = tetromino.blocks
            tetromino.rotate(clockwise: true)
            tetromino.rotate(clockwise: true)
            tetromino.rotate(clockwise: true)
            tetromino.rotate(clockwise: true)
            #expect(tetromino.blocks == original, "4×CW rotation failed for \(type)")
        }
    }

    @Test func fourCounterClockwiseRotationsRestoreBlocks() {
        for type in TetrominoType.allCases {
            var tetromino = Tetromino(type: type, startPosition: (x: 0, y: 0))
            let original = tetromino.blocks
            tetromino.rotate(clockwise: false)
            tetromino.rotate(clockwise: false)
            tetromino.rotate(clockwise: false)
            tetromino.rotate(clockwise: false)
            #expect(tetromino.blocks == original, "4×CCW rotation failed for \(type)")
        }
    }

    @Test func clockwiseThenCounterClockwiseCancels() {
        for type in TetrominoType.allCases {
            var tetromino = Tetromino(type: type, startPosition: (x: 0, y: 0))
            let original = tetromino.blocks
            tetromino.rotate(clockwise: true)
            tetromino.rotate(clockwise: false)
            #expect(tetromino.blocks == original, "CW+CCW identity failed for \(type)")
        }
    }

    @Test func twoClockwiseEqualsTwoCounterClockwise() {
        // Two 180° rotations from the same start should yield the same result
        for type in TetrominoType.allCases {
            var cw = Tetromino(type: type, startPosition: (x: 0, y: 0))
            var ccw = Tetromino(type: type, startPosition: (x: 0, y: 0))
            cw.rotate(clockwise: true)
            cw.rotate(clockwise: true)
            ccw.rotate(clockwise: false)
            ccw.rotate(clockwise: false)
            #expect(cw.blocks == ccw.blocks, "180° CW ≠ 180° CCW for \(type)")
        }
    }

    // MARK: - Specific Rotation Results

    @Test func tPieceClockwiseFirstRotation() {
        // T-piece initial: (0,0),(1,0),(2,0),(1,1). Pivot index 1 = (1,0).
        // CW rotation around pivot (1,0):
        // (0,0): relX=-1,relY=0 → x'=1+0=1, y'=0-(-1)=1 → (1,1)
        // (1,0): pivot → (1,0)
        // (2,0): relX=1,relY=0  → x'=1+0=1, y'=0-1=-1 → (1,-1)
        // (1,1): relX=0,relY=1  → x'=1+1=2, y'=0-0=0 → (2,0)
        var tetromino = Tetromino(type: .t, startPosition: (x: 0, y: 0))
        tetromino.rotate(clockwise: true)
        let expected: Set<Block> = [Block(x: 1, y: 1), Block(x: 1, y: 0), Block(x: 1, y: -1), Block(x: 2, y: 0)]
        #expect(Set(tetromino.blocks) == expected)
    }

    @Test func rotationChangesBlocks() {
        // Every non-O piece should have different blocks after rotation
        let rotatableTypes: [TetrominoType] = [.i, .t, .j, .l, .s, .z]
        for type in rotatableTypes {
            var tetromino = Tetromino(type: type, startPosition: (x: 0, y: 0))
            let original = tetromino.blocks
            tetromino.rotate(clockwise: true)
            #expect(tetromino.blocks != original, "\(type) blocks should change after rotation")
        }
    }

    // MARK: - Codable

    @Test func codableRoundTripPreservesAllFields() throws {
        var original = Tetromino(type: .j, startPosition: (x: 4, y: 2))
        original.rotate()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Tetromino.self, from: data)
        #expect(decoded.type == original.type)
        #expect(decoded.blocks == original.blocks)
        #expect(decoded.position.x == original.position.x)
        #expect(decoded.position.y == original.position.y)
        #expect(decoded.rotation == original.rotation)
    }

    @Test func codableRoundTripForAllTypes() throws {
        for type in TetrominoType.allCases {
            let original = Tetromino(type: type, startPosition: (x: 3, y: 7))
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(Tetromino.self, from: data)
            #expect(decoded.type == original.type, "\(type) type mismatch")
            #expect(decoded.blocks == original.blocks, "\(type) blocks mismatch")
            #expect(decoded.position.x == original.position.x, "\(type) position.x mismatch")
            #expect(decoded.position.y == original.position.y, "\(type) position.y mismatch")
        }
    }

    @Test func codableRoundTripAfterRotation() throws {
        for type in TetrominoType.allCases {
            var original = Tetromino(type: type, startPosition: (x: 0, y: 0))
            original.rotate()
            original.rotate()
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(Tetromino.self, from: data)
            #expect(decoded.blocks == original.blocks, "\(type) post-rotation blocks mismatch")
            #expect(decoded.rotation == original.rotation, "\(type) rotation state mismatch")
        }
    }
}
