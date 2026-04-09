//
//  TetrominoTypeTests.swift
//  NeotrisTests
//

import Testing
import SwiftUI
@testable import Neotris

struct TetrominoTypeTests {

    // MARK: - CaseIterable

    @Test func allCasesCountIsSeven() {
        #expect(TetrominoType.allCases.count == 7)
    }

    @Test func allExpectedCasesPresent() {
        let expected: Set<TetrominoType> = [.i, .o, .t, .j, .l, .s, .z]
        #expect(Set(TetrominoType.allCases) == expected)
    }

    // MARK: - Colors

    @Test func iColorIsCyan() {
        #expect(TetrominoType.i.color == .cyan)
    }

    @Test func oColorIsYellow() {
        #expect(TetrominoType.o.color == .yellow)
    }

    @Test func tColorIsPurple() {
        #expect(TetrominoType.t.color == .purple)
    }

    @Test func jColorIsBlue() {
        #expect(TetrominoType.j.color == .blue)
    }

    @Test func lColorIsOrange() {
        #expect(TetrominoType.l.color == .orange)
    }

    @Test func sColorIsGreen() {
        #expect(TetrominoType.s.color == .green)
    }

    @Test func zColorIsRed() {
        #expect(TetrominoType.z.color == .red)
    }

    @Test func allTypesHaveDistinctColors() {
        // Each type should map to a unique color
        let colors = TetrominoType.allCases.map { $0.color }
        // SwiftUI Colors are not directly Hashable in all versions, so we compare count via
        // checking each pair for uniqueness
        for i in 0..<colors.count {
            for j in (i + 1)..<colors.count {
                #expect(colors[i] != colors[j], "Types at indices \(i) and \(j) share a color")
            }
        }
    }

    // MARK: - Block Shapes

    @Test func eachTypeHasExactlyFourBlocks() {
        for type in TetrominoType.allCases {
            #expect(type.blocks.count == 4, "\(type) should have 4 blocks")
        }
    }

    @Test func noDuplicateBlocksWithinAnyType() {
        for type in TetrominoType.allCases {
            let unique = Set(type.blocks)
            #expect(unique.count == type.blocks.count, "\(type) has duplicate blocks")
        }
    }

    @Test func iBlocksFormHorizontalLine() {
        let blocks = TetrominoType.i.blocks
        #expect(blocks.allSatisfy { $0.y == 0 })
        #expect(Set(blocks.map { $0.x }) == [0, 1, 2, 3])
    }

    @Test func oBlocksFormSquare() {
        let blocks = TetrominoType.o.blocks
        #expect(Set(blocks.map { $0.x }) == [0, 1])
        #expect(Set(blocks.map { $0.y }) == [0, 1])
    }

    @Test func tBlocksContainCenterPivot() {
        // T-piece pivot is blocks[1] = (1,0)
        let blocks = TetrominoType.t.blocks
        #expect(blocks[TetrominoType.t.pivotIndex] == Block(x: 1, y: 0))
    }

    // MARK: - Pivot Index

    @Test func pivotIndexInBoundsForAllTypes() {
        for type in TetrominoType.allCases {
            #expect(type.pivotIndex >= 0, "\(type) pivot index should be non-negative")
            #expect(type.pivotIndex < type.blocks.count, "\(type) pivot index out of bounds")
        }
    }

    @Test func oPivotIndexIsZero() {
        // O doesn't rotate; pivot is unused but defined as 0
        #expect(TetrominoType.o.pivotIndex == 0)
    }

    @Test func iPivotIndexIsOne() {
        #expect(TetrominoType.i.pivotIndex == 1)
    }

    // MARK: - Codable

    @Test func codableRoundTripForAllTypes() throws {
        for type in TetrominoType.allCases {
            let data = try JSONEncoder().encode(type)
            let decoded = try JSONDecoder().decode(TetrominoType.self, from: data)
            #expect(decoded == type, "\(type) failed Codable round-trip")
        }
    }

    @Test func rawValueIsLowercaseName() {
        #expect(TetrominoType.i.rawValue == "i")
        #expect(TetrominoType.o.rawValue == "o")
        #expect(TetrominoType.t.rawValue == "t")
        #expect(TetrominoType.j.rawValue == "j")
        #expect(TetrominoType.l.rawValue == "l")
        #expect(TetrominoType.s.rawValue == "s")
        #expect(TetrominoType.z.rawValue == "z")
    }
}
