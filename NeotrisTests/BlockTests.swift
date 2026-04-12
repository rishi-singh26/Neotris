//
//  BlockTests.swift
//  NeotrisTests
//

import Testing
import Foundation
@testable import Neotris

struct BlockTests {

    @Test func initializationSetsCoordinates() {
        let block = Block(x: 3, y: 7)
        #expect(block.x == 3)
        #expect(block.y == 7)
    }

    @Test func zeroCoordinates() {
        let block = Block(x: 0, y: 0)
        #expect(block.x == 0)
        #expect(block.y == 0)
    }

    @Test func negativeCoordinates() {
        let block = Block(x: -2, y: -5)
        #expect(block.x == -2)
        #expect(block.y == -5)
    }

    @Test func blocksWithSameCoordinatesAreEqual() {
        let a = Block(x: 2, y: 4)
        let b = Block(x: 2, y: 4)
        #expect(a == b)
    }

    @Test func blocksWithDifferentXAreNotEqual() {
        let a = Block(x: 1, y: 2)
        let b = Block(x: 3, y: 2)
        #expect(a != b)
    }

    @Test func blocksWithDifferentYAreNotEqual() {
        let a = Block(x: 1, y: 2)
        let b = Block(x: 1, y: 4)
        #expect(a != b)
    }

    @Test func blocksWithBothDifferentAreNotEqual() {
        let a = Block(x: 1, y: 2)
        let b = Block(x: 3, y: 4)
        #expect(a != b)
    }

    @Test func blockIsUsableInSet() {
        let block1 = Block(x: 1, y: 1)
        let block2 = Block(x: 2, y: 2)
        let set: Set<Block> = [block1, block2, block1]
        #expect(set.count == 2)
    }

    @Test func duplicateBlocksCollapsedInSet() {
        let blocks = [Block(x: 0, y: 0), Block(x: 0, y: 0), Block(x: 1, y: 1)]
        let set = Set(blocks)
        #expect(set.count == 2)
    }

    @Test func codableRoundTrip() throws {
        let original = Block(x: 5, y: 9)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Block.self, from: data)
        #expect(decoded.x == original.x)
        #expect(decoded.y == original.y)
    }

    @Test func codableRoundTripWithNegativeValues() throws {
        let original = Block(x: -3, y: -7)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Block.self, from: data)
        #expect(decoded.x == original.x)
        #expect(decoded.y == original.y)
    }

    @Test func blockArrayCodableRoundTrip() throws {
        let blocks = [Block(x: 0, y: 0), Block(x: 1, y: 0), Block(x: 2, y: 0), Block(x: 3, y: 0)]
        let data = try JSONEncoder().encode(blocks)
        let decoded = try JSONDecoder().decode([Block].self, from: data)
        #expect(decoded == blocks)
    }
}
