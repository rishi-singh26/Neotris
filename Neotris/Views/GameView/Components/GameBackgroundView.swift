//
//  GameBackgroundView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct GameBackgroundView: View {
    private let backgroundColors = [
        Color(hex: "FDA504"), Color(hex: "F78A12"), Color(hex: "F68913"),
        Color(hex: "FF3C2F"), Color(hex: "AC537F"), Color(hex: "D66A4F"),
        Color(hex: "DE7A1C"), Color(hex: "996062"), Color(hex: "5856D6"),
        Color(hex: "FF2C55"), Color(hex: "DA9F26"), Color(hex: "E7B438")
    ]

    var body: some View {
        MeshGradient(
            width: 3,
            height: 4,
            points: [
                [0, 0], [0.5, 0], [1.0, 0],
                [0, 0.4], [0.5, 0.4], [1.0, 0.4],
                [0, 0.7], [0.5, 0.7], [1.0, 0.7],
                [0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: backgroundColors
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GameBackgroundView()
}
