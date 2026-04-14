//
//  KeyBinding.swift
//  Neotris
//
//  Created by Rishi Singh on 14/04/26.
//

#if os(macOS)
import AppKit

// MARK: - GameAction

enum GameAction: String, CaseIterable, Codable {
    case moveLeft
    case moveRight
    case rotate
    case hardDrop
    case pause
    case resume

    var displayName: String {
        switch self {
        case .moveLeft:  return "Move Left"
        case .moveRight: return "Move Right"
        case .rotate:    return "Rotate"
        case .hardDrop:  return "Hard Drop"
        case .pause:     return "Pause"
        case .resume:    return "Resume"
        }
    }

    /// Default key bindings for this action (up to 3).
    var defaultBindings: [KeyBinding] {
        switch self {
        case .moveLeft:  return [KeyBinding(keyCode: 123, modifierFlags: 0)]  // ←
        case .moveRight: return [KeyBinding(keyCode: 124, modifierFlags: 0)]  // →
        case .rotate:    return [KeyBinding(keyCode: 126, modifierFlags: 0)]  // ↑
        case .hardDrop:  return [KeyBinding(keyCode: 125, modifierFlags: 0)]  // ↓
        case .pause:     return [KeyBinding(keyCode: 35,  modifierFlags: 0)]  // P
        case .resume:    return [KeyBinding(keyCode: 15,  modifierFlags: 0)]  // R
        }
    }
}

// MARK: - KeyBinding

/// Maximum number of shortcuts allowed per action.
let maxBindingsPerAction = 3

struct KeyBinding: Codable, Equatable {
    var keyCode: UInt16
    var modifierFlags: UInt  // Only user-pressed modifier keys: ⌃ ⌥ ⇧ ⌘

    /// The modifier flag mask used when both recording and matching shortcuts.
    /// Strips system-injected flags (.function, .numericPad) that arrow/special
    /// keys set automatically, keeping only the four user-held modifiers.
    static let userModifierMask: NSEvent.ModifierFlags = [.control, .option, .shift, .command]

    /// Human-readable string, e.g. "⌘ ←", "R", "↑", "Space"
    var displayString: String {
        let mods = NSEvent.ModifierFlags(rawValue: modifierFlags)
        var parts: [String] = []
        if mods.contains(.control)  { parts.append("⌃") }
        if mods.contains(.option)   { parts.append("⌥") }
        if mods.contains(.shift)    { parts.append("⇧") }
        if mods.contains(.command)  { parts.append("⌘") }
        parts.append(Self.keyCodeDisplayName(keyCode))
        return parts.joined(separator: " ")
    }

    // swiftlint:disable cyclomatic_complexity
    static func keyCodeDisplayName(_ keyCode: UInt16) -> String {
        switch keyCode {
        // Arrow keys
        case 123: return "←"
        case 124: return "→"
        case 125: return "↓"
        case 126: return "↑"
        // Special keys
        case 49:  return "Space"
        case 36:  return "↩"
        case 48:  return "⇥"
        case 51:  return "⌫"
        case 53:  return "Esc"
        case 117: return "⌦"
        // Letter keys (US QWERTY layout)
        case 0:   return "A"
        case 11:  return "B"
        case 8:   return "C"
        case 2:   return "D"
        case 14:  return "E"
        case 3:   return "F"
        case 5:   return "G"
        case 4:   return "H"
        case 34:  return "I"
        case 38:  return "J"
        case 40:  return "K"
        case 37:  return "L"
        case 46:  return "M"
        case 45:  return "N"
        case 31:  return "O"
        case 35:  return "P"
        case 12:  return "Q"
        case 15:  return "R"
        case 1:   return "S"
        case 17:  return "T"
        case 32:  return "U"
        case 9:   return "V"
        case 13:  return "W"
        case 7:   return "X"
        case 16:  return "Y"
        case 6:   return "Z"
        // Number keys
        case 29:  return "0"
        case 18:  return "1"
        case 19:  return "2"
        case 20:  return "3"
        case 21:  return "4"
        case 23:  return "5"
        case 22:  return "6"
        case 26:  return "7"
        case 28:  return "8"
        case 25:  return "9"
        // Function keys
        case 122: return "F1"
        case 120: return "F2"
        case 99:  return "F3"
        case 118: return "F4"
        case 96:  return "F5"
        case 97:  return "F6"
        case 98:  return "F7"
        case 100: return "F8"
        case 101: return "F9"
        case 109: return "F10"
        case 103: return "F11"
        case 111: return "F12"
        default:  return "Key \(keyCode)"
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
#endif
