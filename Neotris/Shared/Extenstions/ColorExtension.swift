//
//  ColorExtension.swift
//  Neotris
//
//  Created by Rishi Singh on 03/03/25.
//

import SwiftUI

extension Color {
    /// Initialize a Color using a hex code
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var int: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&int)

        let r, g, b, a: Double
         switch hexSanitized.count {
         case 6: // RGB (e.g., "#RRGGBB")
             r = Double((int >> 16) & 0xFF) / 255.0
             g = Double((int >> 8) & 0xFF) / 255.0
             b = Double(int & 0xFF) / 255.0
             a = 1.0
         case 8: // RGBA (e.g., "#RRGGBBAA")
             r = Double((int >> 24) & 0xFF) / 255.0
             g = Double((int >> 16) & 0xFF) / 255.0
             b = Double((int >> 8) & 0xFF) / 255.0
             a = Double(int & 0xFF) / 255.0
         default:
             r = 0
             g = 0
             b = 0
             a = 1.0
         }
         
         self.init(red: r, green: g, blue: b, opacity: a)
    }
}

// Extension to the Color class to calculate foreground color based on background color luminance
extension Color {
    
    init(forBackground color: Color) {
        #if os(iOS)
        // For iOS, use UIColor
        let uiColor = UIColor(color)
        let components = uiColor.cgColor.components ?? [0, 0, 0]
        #elseif os(macOS)
        // For macOS, use NSColor
        let nsColor = NSColor(color)
        let components = nsColor.cgColor.components ?? [0, 0, 0]
        #else
        fatalError("Unsupported platform")
        #endif

        let red = components[0]
        let green = components[1]
        let blue = components[2]

        // Formula to calculate relative luminance
        let r = red * 0.2126
        let g = green * 0.7152
        let b = blue * 0.0722

        let lum = r + g + b
        // If luminance is high, return black (dark text on light background), else return white (light text on dark background)
        let colorLevel: Double = lum > 0.7 ? 0.0 : 1.0
        self.init(red: colorLevel, green: colorLevel, blue: colorLevel, opacity: 1)
    }
}

// Extends Color to add retro theme colors
extension Color {
    static let retroBackground = Color(red: 0.0, green: 0.0, blue: 0.1) // #00001A
    static let retroGrid = Color(red: 0.2, green: 0.2, blue: 0.3) // #33334D
    static let retroAccent = Color(red: 0.9, green: 0.2, blue: 0.8) // #E533CC
    static let retroText = Color(red: 0.9, green: 0.9, blue: 1.0) // #E5E5FF
    static let retroGold = Color(red: 1.0, green: 0.84, blue: 0.0) // #FFD600
}
