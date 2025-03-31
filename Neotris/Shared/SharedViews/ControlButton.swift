//
//  ControlButton.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct ControlButton: View {
    var iconName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .frame(width: DeviceType.current == .iPhone ? 65 : 95, height: 65)
                .background(.thinMaterial)
                .font(.title2.bold())
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ControlButton(iconName: "arrow.down.to.line.compact") {
        print("Hello")
    }
}
