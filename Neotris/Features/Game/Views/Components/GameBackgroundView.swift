//
//  GameBackgroundView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct GameBackgroundView: View {
    @Environment(GameViewModel.self) private var viewModel

    private let defaultBackgroundColors = [
        Color(hex: "FDA504"), Color(hex: "F78A12"), Color(hex: "F68913"),
        Color(hex: "FF3C2F"), Color(hex: "AC537F"), Color(hex: "D66A4F"),
        Color(hex: "DE7A1C"), Color(hex: "996062"), Color(hex: "5856D6"),
        Color(hex: "FF2C55"), Color(hex: "DA9F26"), Color(hex: "E7B438")
    ]

    private let defaultPoints: [SIMD2<Float>] = [
        [0, 0], [0.5, 0], [1.0, 0],
        [0, 0.4], [0.5, 0.4], [1.0, 0.4],
        [0, 0.7], [0.5, 0.7], [1.0, 0.7],
        [0, 1.0], [0.5, 1.0], [1.0, 1.0]
    ]

    var body: some View {
        if #available(macOS 15.0, *) {
            let snapshot = viewModel.activeThemeSnapshot
            MeshGradient(
                width: snapshot?.meshWidth ?? 3,
                height: snapshot?.meshHeight ?? 4,
                points: snapshot?.simdPoints ?? defaultPoints,
                colors: snapshot?.resolvedMeshColors ?? defaultBackgroundColors
            )
            .ignoresSafeArea()
        } else {
            Color(hex: "FDA504")
                .ignoresSafeArea()
        }
    }
}

#Preview {
    GameBackgroundView()
        .environment(GameViewModel())
}
