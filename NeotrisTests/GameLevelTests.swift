//
//  GameLevelTests.swift
//  NeotrisTests
//

import Testing
import Foundation
@testable import Neotris

struct GameLevelTests {

    // MARK: - Initial State

    @Test func initialLevel() {
        let level = GameLevel()
        #expect(level.level == 1)
    }

    @Test func initialLinesCleared() {
        let level = GameLevel()
        #expect(level.linesCleared == 0)
    }

    @Test func initialMaxLevel() {
        let level = GameLevel()
        #expect(level.maxLevel == 15)
    }

    // MARK: - Drop Speed

    @Test func dropSpeedAtLevel1IsOne() {
        let level = GameLevel()
        // max(0.1, 1.0 / (1.0 + 0.15 * 0)) = 1.0
        #expect(abs(level.dropSpeed - 1.0) < 0.001)
    }

    @Test func dropSpeedDecreaseAsLevelIncreases() {
        var level = GameLevel()
        var previousSpeed = level.dropSpeed
        for _ in 1..<15 {
            _ = level.addLines(5)
            let currentSpeed = level.dropSpeed
            #expect(currentSpeed <= previousSpeed, "Speed should not increase at level \(level.level)")
            previousSpeed = currentSpeed
        }
    }

    @Test func dropSpeedAtLevel2() {
        var level = GameLevel()
        _ = level.addLines(5)
        // Level 2: 1.0 / (1.0 + 0.15 * 1) = 1/1.15 ≈ 0.8696
        let expected = 1.0 / (1.0 + 0.15 * 1.0)
        #expect(abs(level.dropSpeed - expected) < 0.001)
    }

    @Test func dropSpeedNeverBelowMinimum() {
        var level = GameLevel()
        _ = level.addLines(200)
        #expect(level.dropSpeed >= 0.1)
    }

    @Test func dropSpeedFormulaAtAnyLevel() {
        for lvl in 1...15 {
            var level = GameLevel()
            level.level = lvl
            let expected = max(0.1, 1.0 / (1.0 + 0.15 * Double(lvl - 1)))
            #expect(abs(level.dropSpeed - expected) < 0.001, "Formula mismatch at level \(lvl)")
        }
    }

    // MARK: - Speed Percentage

    @Test func speedPercentageAtLevel1IsZero() {
        let level = GameLevel()
        #expect(level.speedPercentage == 0)
    }

    @Test func speedPercentageIncreasesWithLevel() {
        var level = GameLevel()
        let pct1 = level.speedPercentage
        _ = level.addLines(5)
        let pct2 = level.speedPercentage
        #expect(pct2 > pct1)
    }

    @Test func speedPercentageNeverExceeds100() {
        var level = GameLevel()
        _ = level.addLines(200)
        #expect(level.speedPercentage <= 100)
    }

    @Test func speedPercentageIsNonNegative() {
        let level = GameLevel()
        #expect(level.speedPercentage >= 0)
    }

    // MARK: - Level Progression

    @Test func addFiveLinesFromLevel1LevelsUp() {
        var level = GameLevel()
        let didLevelUp = level.addLines(5)
        #expect(didLevelUp == true)
        #expect(level.level == 2)
        #expect(level.linesCleared == 5)
    }

    @Test func addFourLinesDoesNotLevelUp() {
        var level = GameLevel()
        let didLevelUp = level.addLines(4)
        #expect(didLevelUp == false)
        #expect(level.level == 1)
        #expect(level.linesCleared == 4)
    }

    @Test func addOneLineAtATimeProgressesLevel() {
        var level = GameLevel()
        var leveledUp = false
        for _ in 0..<5 {
            if level.addLines(1) { leveledUp = true }
        }
        #expect(leveledUp == true)
        #expect(level.level == 2)
    }

    @Test func addTenLinesReachesLevel3() {
        var level = GameLevel()
        _ = level.addLines(10)
        #expect(level.level == 3)
        #expect(level.linesCleared == 10)
    }

    @Test func levelCappedAtMaxLevel() {
        var level = GameLevel()
        _ = level.addLines(200)
        #expect(level.level == level.maxLevel)
    }

    @Test func levelNeverExceedsMaxLevel() {
        var level = GameLevel()
        _ = level.addLines(10000)
        #expect(level.level <= level.maxLevel)
    }

    @Test func addZeroLinesDoesNothing() {
        var level = GameLevel()
        let didLevelUp = level.addLines(0)
        #expect(didLevelUp == false)
        #expect(level.level == 1)
        #expect(level.linesCleared == 0)
    }

    @Test func addFourLinesLevelProgressionEveryFive() {
        // Each batch of 4 clears: 4, 8, 12, 16, 20 lines
        // Level thresholds: 5→L2, 10→L3, 15→L4, 20→L5
        var level = GameLevel()
        _ = level.addLines(4)  // 4 lines, still L1
        #expect(level.level == 1)
        _ = level.addLines(4)  // 8 lines → L2
        #expect(level.level == 2)
        _ = level.addLines(4)  // 12 lines → L3
        #expect(level.level == 3)
    }

    // MARK: - Lines to Next Level

    @Test func linesToNextLevelAtStart() {
        let level = GameLevel()
        // level=1, linesCleared=0, nextLevelLines=1*5=5
        #expect(level.linesToNextLevel == 5)
    }

    @Test func linesToNextLevelAfterThreeLines() {
        var level = GameLevel()
        _ = level.addLines(3)
        // level=1, linesCleared=3, nextLevelLines=5, linesToNextLevel=2
        #expect(level.linesToNextLevel == 2)
    }

    @Test func linesToNextLevelAfterLevelUp() {
        var level = GameLevel()
        _ = level.addLines(5)
        // level=2, linesCleared=5, nextLevelLines=2*5=10, linesToNextLevel=5
        #expect(level.linesToNextLevel == 5)
    }

    @Test func linesToNextLevelAtLevel3() {
        var level = GameLevel()
        _ = level.addLines(12)
        // level=3, linesCleared=12, nextLevelLines=3*5=15, linesToNextLevel=3
        #expect(level.linesToNextLevel == 3)
    }

    // MARK: - Codable

    @Test func codableRoundTrip() throws {
        var level = GameLevel()
        _ = level.addLines(7)
        let data = try JSONEncoder().encode(level)
        let decoded = try JSONDecoder().decode(GameLevel.self, from: data)
        #expect(decoded.level == level.level)
        #expect(decoded.linesCleared == level.linesCleared)
        #expect(decoded.maxLevel == level.maxLevel)
    }

    @Test func codableRoundTripAtHighLevel() throws {
        var level = GameLevel()
        _ = level.addLines(74)  // level 15 (capped)
        let data = try JSONEncoder().encode(level)
        let decoded = try JSONDecoder().decode(GameLevel.self, from: data)
        #expect(decoded.level == level.level)
        #expect(decoded.linesCleared == level.linesCleared)
    }
}
