# Keyboard Shortcuts — Implementation Reference

**Platform:** macOS only (`#if os(macOS)` guards throughout)  
**Feature:** Fully customisable per-action key bindings, up to 3 shortcuts per action, persisted to UserDefaults.

---

## Table of Contents

1. [Overview](#overview)
2. [File Map](#file-map)
3. [Data Model](#data-model)
4. [Persistence](#persistence)
5. [Game Integration](#game-integration)
6. [Settings UI](#settings-ui)
7. [Default Bindings](#default-bindings)
8. [Key Design Decisions](#key-design-decisions)
9. [Known Constraints](#known-constraints)
10. [How to Extend](#how-to-extend)

---

## Overview

The keyboard shortcuts system lets macOS users remap any game control to up to 3 key combinations each (plain keys or keys with ⌘ ⌥ ⌃ ⇧ modifiers). Changes take effect immediately without restart and survive app relaunch via UserDefaults.

Data flows in one direction:

```
UserDefaults
    ↓ load on init
GameViewModel.keyBindings  ([String: [KeyBinding]])
    ↓ read at every key press
TetrisGameView (NSEvent monitor)
    ↓ update on assignment
UserDefaults  (via didSet → saveKeyBindings)
```

The Settings UI (`ControlsSettingsView`) reads from and writes to `GameViewModel.keyBindings` directly, which propagates to both the NSEvent monitor and UserDefaults automatically.

---

## File Map

| File | Role |
|------|------|
| `Neotris/Models/KeyBinding.swift` | `GameAction` enum, `KeyBinding` struct, key-code → display name table, `maxBindingsPerAction` constant, `userModifierMask` |
| `Neotris/Features/Game/ViewModels/GameViewModel.swift` | `keyBindings` stored property, `bindings(for:)` accessor, `loadKeyBindings()` / `saveKeyBindings(_:)` static helpers |
| `Neotris/Features/Game/Views/TetrisGameView.swift` | NSEvent monitor setup/teardown, `matches(_:_:)` helper |
| `Neotris/Features/Settings/ControlsSettingsView.swift` | Settings page UI — badge display, click-to-record, add/remove, reset, conflict detection |
| `Neotris/Features/Settings/SettingsView.swift` | Adds `.controlsPage` to `SettingPage` enum and wires `ControlsSettingsView` into the macOS sidebar |

---

## Data Model

### `GameAction` (`KeyBinding.swift`)

An enum listing every remappable game control:

```swift
enum GameAction: String, CaseIterable, Codable {
    case moveLeft
    case moveRight
    case rotate
    case hardDrop
    case pause
    case resume
}
```

Each case provides:

- `displayName: String` — human-readable label shown in the settings UI (e.g. `"Move Left"`)
- `defaultBindings: [KeyBinding]` — the out-of-the-box shortcuts for this action (one entry each by default; see [Default Bindings](#default-bindings))

`GameAction` conforms to `CaseIterable` so the settings UI can enumerate all actions in order, and to `Codable` so it can be used as a dictionary key when serialised.

---

### `KeyBinding` (`KeyBinding.swift`)

A lightweight `Codable, Equatable` struct representing one key combination:

```swift
struct KeyBinding: Codable, Equatable {
    var keyCode: UInt16   // NSEvent virtual key code
    var modifierFlags: UInt  // Only user-held modifier bits (see userModifierMask)
}
```

**`KeyBinding.userModifierMask`**

```swift
static let userModifierMask: NSEvent.ModifierFlags = [.control, .option, .shift, .command]
```

This mask is applied consistently in **two** places:

1. **Recording** (`ControlsSettingsView.startRecording`) — strips `.function` and `.numericPad` before storing.
2. **Matching** (`TetrisGameView.matches(_:_:)`) — strips the same flags before comparing against a stored binding.

> **Why this matters:** macOS injects `.function` (0x800000) and `.numericPad` (0x200000) into the `modifierFlags` of arrow keys and other special keys automatically, even when the user holds no modifier. Both flags are within `deviceIndependentFlagsMask`, so using the full mask causes arrow key default bindings (stored with `modifierFlags: 0`) to never match. The `userModifierMask` strips these system-injected flags and keeps only the four user-pressed modifiers.

**`KeyBinding.displayString`**

Produces human-readable labels (e.g. `"⌘ ←"`, `"Space"`, `"R"`) by reading the modifier flags and looking up the key code in `keyCodeDisplayName(_:)`. Only the four user modifier symbols are rendered; `.function` and `.numericPad` are intentionally excluded.

**`KeyBinding.keyCodeDisplayName(_:)`**

A static `switch` covering:
- Arrow keys (123–126)
- Special keys: Space (49), Return (36), Tab (48), Delete (51), Escape (53), Forward-delete (117)
- Letters A–Z (US QWERTY layout key codes)
- Digits 0–9
- Function keys F1–F12
- Fallback: `"Key \(keyCode)"` for anything not in the table

**`maxBindingsPerAction`**

A file-level constant set to `3`. Controls the maximum number of shortcuts per action across the entire feature (enforced in both the UI and the recording handler).

---

## Persistence

### Storage location

`UserDefaults.standard`, key `"keyBindings"`.

### Format

JSON-encoded `[String: [KeyBinding]]`, where the string key is `GameAction.rawValue` (e.g. `"moveLeft"`).

Example stored value:

```json
{
  "moveLeft":  [{"keyCode": 123, "modifierFlags": 0}, {"keyCode": 0, "modifierFlags": 0}],
  "rotate":    [{"keyCode": 126, "modifierFlags": 0}]
}
```

Actions whose bindings have never been changed (or have been reset) are **stored explicitly** with their default values — not omitted. This guarantees that a reset is persisted and old custom shortcuts are purged from disk.

> **Important:** On first launch (no stored value) `loadKeyBindings()` returns `[:]`. The `bindings(for:)` accessor then falls through to `action.defaultBindings`. This is the only code path that uses the nil-fallback; after the user touches any binding (including reset), the action's entry is always present in the dictionary.

### `GameViewModel` — storage property

```swift
// macOS only
var keyBindings: [String: [KeyBinding]] {
    didSet { Self.saveKeyBindings(keyBindings) }
}
```

Mutations to this dictionary (subscript assignment, remove) trigger `didSet`, which immediately JSON-encodes and writes to UserDefaults. The `@Observable` macro ensures SwiftUI views observing `keyBindings` re-render on change.

### `bindings(for:)` accessor

```swift
func bindings(for action: GameAction) -> [KeyBinding] {
    keyBindings[action.rawValue] ?? action.defaultBindings
}
```

Single read point used by both the NSEvent monitor and the settings UI. Never call `keyBindings[rawValue]` directly from the game or UI layers; always go through this accessor.

### Static helpers

```swift
static func loadKeyBindings() -> [String: [KeyBinding]]   // called in init
static func saveKeyBindings(_ bindings: [String: [KeyBinding]])  // called by didSet
```

Both use `JSONDecoder` / `JSONEncoder`. Encoding errors are silently swallowed (bindings are non-critical data).

---

## Game Integration

### `TetrisGameView` — NSEvent monitor

**Setup** (`setupKeyboardControls()`, called from `.onAppear`):

```swift
guard keyEventMonitor == nil else { return }
keyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
    // resume check runs even when paused
    if viewModel.gameState == .paused && self.matches(event, .resume) {
        viewModel.resumeGame(); return nil
    }
    guard viewModel.gameState == .playing else { return event }
    if self.matches(event, .moveLeft)  { viewModel.moveLeft();  return nil }
    if self.matches(event, .moveRight) { viewModel.moveRight(); return nil }
    if self.matches(event, .hardDrop)  { viewModel.hardDrop();  return nil }
    if self.matches(event, .rotate)    { viewModel.rotate();    return nil }
    if self.matches(event, .pause)     { viewModel.pauseGame(); return nil }
    return event
}
```

The `guard` prevents stacking duplicate monitors across reappears (e.g. dismissing a sheet).

**Teardown** (`tearDownKeyboardControls()`, called from `.onDisappear`):

```swift
if let monitor = keyEventMonitor {
    NSEvent.removeMonitor(monitor)
    keyEventMonitor = nil
}
```

**Matching helper:**

```swift
private func matches(_ event: NSEvent, _ action: GameAction) -> Bool {
    let eventMods = event.modifierFlags.intersection(KeyBinding.userModifierMask).rawValue
    return viewModel.bindings(for: action).contains { binding in
        event.keyCode == binding.keyCode && eventMods == binding.modifierFlags
    }
}
```

Uses `.contains` over the full array so **all** assigned shortcuts trigger the action simultaneously.

### Event consumption

The monitor returns `nil` to consume a matched event (preventing it from reaching text fields or system handlers), or `event` to pass it through. Events are only consumed when the match succeeds AND the game is in the right state.

---

## Settings UI

### Navigation entry point

`SettingsView.swift` — macOS `NavigationSplitView`:

```swift
// SettingPage enum
case controlsPage

// Sidebar
NavigationLink(value: SettingPage.controlsPage) {
    Label("Controls", systemImage: "keyboard")
}

// Detail panel
case .controlsPage:
    ControlsSettingsView().navigationTitle("Controls")
```

### `ControlsSettingsView`

Renders one row per `GameAction` inside a `MacCustomSection`. State:

```swift
@State private var recording: RecordingState?   // which action+slot is recording
@State private var keyMonitor: Any?             // the temporary NSEvent monitor
```

#### `RecordingState`

```swift
private struct RecordingState: Equatable {
    let action: GameAction
    let slot: Slot

    enum Slot: Equatable {
        case replacing(Int)   // editing existing binding at index
        case adding           // appending a new binding
    }
}
```

Using an enum for the slot (rather than `Int?`) avoids a Swift double-optional pitfall: `recording?.slot == .adding` is an unambiguous `Equatable` comparison, whereas `recording?.index == nil` where `index: Int?` would produce `Int??` and always evaluate to `false` when `recording` is non-nil (because `Optional.some(nil) != Optional.none`).

#### Row layout (non-recording state)

```
[ Action Name (130pt) ]  [ badge ][ ✕ ]  [ badge ][ ✕ ]  [ + ]  [ ↺ ]
```

- Each **badge** shows `KeyBinding.displayString` and is tappable to replace that slot.
- **✕** removes that badge (disabled / hidden when only one binding remains).
- **+** appends a new binding (disabled when count == `maxBindingsPerAction`).
- **↺** resets all bindings for this action to `action.defaultBindings` (disabled when already at defaults).

#### Row layout (recording state)

```
[ Action Name ]  [ other badges ]  [ Press any key… ]  [ Cancel ]
```

The badge at the recording slot is replaced by the "Press any key…" indicator. Other badges remain visible.

#### Recording flow

1. `startRecording(action:slot:)` calls `stopRecording()` (cleans up any prior monitor), sets `recording`, and registers a new temporary `NSEvent.addLocalMonitorForEvents` monitor.
2. On Escape (key code 53): calls `stopRecording()` — no change saved.
3. On any other key: captures `event.keyCode` and `event.modifierFlags.intersection(userModifierMask).rawValue`, constructs a `KeyBinding`, mutates the current bindings array (replace or append), writes back to `viewModel.keyBindings[action.rawValue]`, then calls `stopRecording()`.
4. `stopRecording()` removes the monitor, nils `keyMonitor`, and nils `recording`.
5. `.onDisappear` calls `stopRecording()` to prevent a leaked monitor if the user navigates away mid-recording.

#### Conflict detection

`conflictingActions(for:)` returns every other `GameAction` whose binding array intersects with the current action's binding array. A warning label is shown beneath the row for each conflict. Conflicts are non-blocking — the binding is saved regardless, letting the user resolve the overlap manually.

#### Reset

```swift
private func resetBindings(for action: GameAction) {
    viewModel.keyBindings[action.rawValue] = action.defaultBindings
}
```

Writes defaults explicitly rather than removing the key. This guarantees `didSet` fires via an unambiguous property assignment and that old custom shortcuts are immediately purged from both memory and UserDefaults.

---

## Default Bindings

| Action | Default key | Key code |
|--------|-------------|----------|
| Move Left | ← | 123 |
| Move Right | → | 124 |
| Rotate | ↑ | 126 |
| Hard Drop | ↓ | 125 |
| Pause | P | 35 |
| Resume | R | 15 |

All defaults use `modifierFlags: 0` (no user modifier held).

---

## Key Design Decisions

### 1. `userModifierMask` instead of `deviceIndependentFlagsMask`

macOS injects `.function` and `.numericPad` into the `modifierFlags` of arrow keys regardless of user input. Using `deviceIndependentFlagsMask` (which includes these bits) causes the default ← → ↑ ↓ bindings — stored with `modifierFlags: 0` — to never match a live event. `userModifierMask = [.control, .option, .shift, .command]` strips those system bits, giving `modifierFlags: 0` for any bare key press.

### 2. Explicit default storage on reset (no `removeValue`)

When a user resets an action, `keyBindings[action.rawValue]` is set to `action.defaultBindings` rather than removed. Removing the key makes `bindings(for:)` fall back silently through `??`, which relies on the nil-path being equivalent to defaults. Explicit storage is clearer, guarantees `didSet` fires via a proper assignment, and persists the reset to UserDefaults so custom shortcuts are removed even after restart.

### 3. `RecordingState.slot` as an enum, not `Int?`

Using `Int?` for the recording slot creates a double-optional when accessed via optional chaining (`recording?.index` → `Int??`). `Optional.some(nil) != Optional.none` in Swift, so the `.adding` indicator badge would never render. The `Slot` enum sidesteps this entirely.

### 4. Guard against duplicate monitors

`setupKeyboardControls()` stores the monitor handle in `@State private var keyEventMonitor` and guards with `guard keyEventMonitor == nil`. Without this, every `.onAppear` (e.g. dismissing a sheet while game view is underneath) would stack another monitor, causing duplicate action invocations per key press.

### 5. `bindings(for:)` as the single read point

Both the NSEvent monitor and the settings UI read through `GameViewModel.bindings(for:)`. This centralises the nil-fallback-to-defaults logic in one place, making it easy to change default behaviour without touching callers.

---

## Known Constraints

- **macOS only.** The entire feature is wrapped in `#if os(macOS)`. iOS uses swipe gestures and on-screen buttons; there is no keyboard support there.
- **US QWERTY key codes.** `keyCodeDisplayName(_:)` maps hardware key codes to letter labels assuming a US layout. On non-US keyboards the displayed label may differ from the physical key.
- **No duplicate detection within one action.** A user can assign the same shortcut twice to the same action (e.g. two `←` entries). It is harmless (both entries match the same event) but wasteful. The UI does not warn about this.
- **No system shortcut conflict checking.** Bindings are not validated against system-level shortcuts (⌘Q, ⌘W, etc.). If the user assigns one of those, the game will consume it before the system can act on it during gameplay.
- **`modifierFlags` is stored as `UInt`.** `NSEvent.ModifierFlags` is not directly `Codable`, so its `.rawValue` (a `UInt`) is stored instead. Reconstruction via `NSEvent.ModifierFlags(rawValue:)` is lossless.

---

## How to Extend

### Add a new game action

1. **`KeyBinding.swift`** — add a new case to `GameAction`, implement `displayName` and `defaultBindings`.
2. **`TetrisGameView.setupKeyboardControls()`** — add a `if self.matches(event, .newAction) { ... }` branch.
3. No changes needed to `ControlsSettingsView`, `GameViewModel`, or `SettingsView` — the new action appears automatically because the UI iterates `GameAction.allCases`.

### Change the shortcut limit

Edit `maxBindingsPerAction` in `KeyBinding.swift`. The UI's `+` button disabled state and the recording guard both read from this constant.

### Add a new key to the display table

Add a `case keyCode: return "Label"` to `KeyBinding.keyCodeDisplayName(_:)`.

### Change the persistence backend (e.g. to iCloud `NSUbiquitousKeyValueStore`)

Replace the body of `GameViewModel.loadKeyBindings()` and `saveKeyBindings(_:)`. The rest of the system is unaffected.

### Make the feature available on iOS

Remove the `#if os(macOS)` guards. On iOS, `NSEvent` is unavailable — replace the monitor with a `UIKeyCommand` or `onKeyPress` approach. `GameViewModel.keyBindings` and `KeyBinding` are pure Swift and require no changes.

### Support non-QWERTY keyboard layouts

Replace the `switch` in `keyCodeDisplayName(_:)` with a lookup using `UCKeyTranslate` (Carbon) or `event.characters(byApplyingModifiers: [])` at record time to get the localised character string and store it alongside the key code.
