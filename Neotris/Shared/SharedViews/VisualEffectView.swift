//
//  VisualEffectView.swift
//  Neotris
//
//  Created by Rishi Singh on 31/03/25.
//

#if os(macOS)
import SwiftUI

// NSVisualEffectView wrapper to use in SwiftUI
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

#Preview {
    VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
}
#endif
