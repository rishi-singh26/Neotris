//
//  AppTips.swift
//  Neotris
//
//  Created by Rishi Singh on 14/04/26.
//

import TipKit

// MARK: - Main Game Screen Tips (popover, sequential)

/// Shown as a popover on the settings button (iOS + macOS).
/// Dismissed by the user; unlocks KeyboardShortcutsTip once dismissed.
struct GameThemesTip: Tip {
    /// Set to true after the user dismisses this tip, which gates KeyboardShortcutsTip.
    @Parameter static var isDismissed: Bool = false

    var title: Text {
        Text("Game Themes")
    }

    var message: Text? {
        Text("Personalize your game with custom color themes for blocks and the board.")
    }

    var image: Image? {
        Image(systemName: "paintpalette.fill")
    }
}

/// Shown as a popover on the settings button (macOS only).
/// Only becomes eligible after GameThemesTip has been dismissed.
struct KeyboardShortcutsTip: Tip {
    var rules: [Rule] {
        #Rule(GameThemesTip.$isDismissed) { $0 == true }
    }

    var title: Text {
        Text("Custom Keyboard Shortcuts")
    }

    var message: Text? {
        Text("Assign your own key bindings for every game action in Settings → Controls.")
    }

    var image: Image? {
        Image(systemName: "keyboard")
    }
}

// MARK: - Feature Screen Tips (inline)

/// Inline tip shown at the top of ThemesListView (iOS + macOS).
struct GameThemesDetailTip: Tip {
    var title: Text {
        Text("Make it yours")
    }

    var message: Text? {
        Text("Use a built-in theme, create a new one, or duplicate a built-in theme and customize it to your liking.")
    }

    var image: Image? {
        Image(systemName: "paintpalette")
    }
}

/// Inline tip shown at the top of ControlsSettingsView (macOS only).
struct KeyboardShortcutsDetailTip: Tip {
    var title: Text {
        Text("Custom Keyboard Shortcuts")
    }

    var message: Text? {
        Text("Assign up to 3 shortcuts per action. Click a badge to reassign it, or press Escape to cancel.")
    }

    var image: Image? {
        Image(systemName: "keyboard.badge.ellipsis")
    }
}
