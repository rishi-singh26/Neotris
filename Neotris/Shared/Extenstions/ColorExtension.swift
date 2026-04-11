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
    
    func withGhostOpacity() -> Color {
        return self.opacity(0.3)
    }

    /// Convert a Color to a 6-digit uppercase hex string (RGB, no alpha)
    func toHexString() -> String {
#if os(iOS)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
#elseif os(macOS)
        let ns = NSColor(self)
        guard let rgb = ns.usingColorSpace(.sRGB) else { return "808080" }
        let r = rgb.redComponent
        let g = rgb.greenComponent
        let b = rgb.blueComponent
#endif
        return String(
            format: "%02X%02X%02X",
            Int((r * 255).rounded()),
            Int((g * 255).rounded()),
            Int((b * 255).rounded())
        )
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
