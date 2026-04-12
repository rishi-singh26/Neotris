# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Neotris is a SwiftUI Tetris game for iOS and macOS, available on the App Store (ID: 6744033137). It uses SwiftData for game history persistence and UserDefaults for in-progress game saves.

**Targets**: iOS 26.4+, macOS 26.4+

## Build & Test

Build and run via Xcode — open `Neotris.xcodeproj`. There is no Makefile or CLI build system.

Tests use Swift's modern `Testing` framework (not XCTest). Run tests via `Cmd+U` in Xcode or:
```
xcodebuild test -project Neotris.xcodeproj -scheme Neotris -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

### Core Game Engine

`Views/GameView/TetrisGameModel.swift` is the heart of the app — an `ObservableObject` (~815 lines) that owns all game state and logic:
- **Board**: 10×20 grid as `[[Color?]]`
- **Game loop**: 60 FPS timer (`0.016s`), drop speed varies by level
- **State machine**: `GameState` enum — `waiting → playing → paused → gameOver`
- **Pieces**: `currentTetromino`, `nextTetromino`, `secondNextTetromino`

Shared app-wide via `@EnvironmentObject` injected at the root in `NeotrisApp.swift`.

### Models Layer (`Models/`)

Pure data structures and logic, no UI dependencies:
- `Tetromino.swift` — active piece with pivot-based rotation; I and O pieces have special-cased rotation
- `TetrominoType.swift` — 7 standard pieces (I, O, T, J, L, S, Z) with colors and shape matrices
- `GameLevel.swift` — levels 1–15; drop speed formula: `max(0.1, 1.0 / (1.0 + 0.15 × (level - 1)))`; level up every 5 cleared lines
- `ScoreSystem.swift` — classic scoring (1 line: 40×level, 4 lines: 1200×level); high score in UserDefaults
- `SavedGameState.swift` — serializes in-progress games to UserDefaults for resume on relaunch
- `TetrisGameSession.swift` — SwiftData model storing completed game stats (score, level, lines, duration)

### Views Layer (`Views/`)

Views are purely presentational; all logic lives in `TetrisGameModel`.

- `TetrisGameView.swift` — top-level container; handles gestures (swipe left/right/down, hard-drop swipe up) and keyboard input (arrow keys, spacebar, R to restart)
- `GameView/Components/GameBoardView.swift` — renders the 10×20 grid including ghost piece (transparent landing preview)
- `GameView/Components/GameRightView.swift` — next piece preview, settings panel
- `SettingsView.swift` — theme (System/Light/Dark), sound, haptics, ghost piece toggle, layout options

Platform-specific layout: iPhone gets a compact vertical layout; iPad/Mac get a wider layout with side panels. `Shared/Utility/DeviceType.swift` handles detection.

### Persistence

Two-tier persistence:
1. **UserDefaults** (`SavedGameState`) — auto-saves in-progress game state on every move; restored on next launch
2. **SwiftData** (`TetrisGameSession`) — appends a record when a game ends; displayed in `GameSessionsListView`

SwiftData container is set up in `NeotrisApp.swift` with a migration plan in `TetrisGameSessionMigrationPlan.swift`.

### Haptics

Custom `CHHapticEngine` patterns in `TetrisGameModel` for: piece movement, rotation, line clears (intensity scales with lines cleared), level-up, and game over.
