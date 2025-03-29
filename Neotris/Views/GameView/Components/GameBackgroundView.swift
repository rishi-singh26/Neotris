//
//  GameBackgroundView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct GameBackgroundView: View {
    private let backgroundColors = [
        Color(hex: "FFCC01"), Color(hex: "FF9500"), Color(hex: "FF2C55"),
        Color(hex: "AF52DE"), Color(hex: "FF3C2F"), Color(hex: "FB5C4C"),
        Color(hex: "007AFF"), Color(hex: "2C8EF3"), Color(hex: "35C759"),
        Color(hex: "51CA70"), Color(hex: "FED702"), Color(hex: "5856D6")
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
