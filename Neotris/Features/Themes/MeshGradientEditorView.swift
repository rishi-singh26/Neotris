//
//  MeshGradientEditorView.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import SwiftUI

// MARK: - Grid Size Options

enum MeshGridSize: String, CaseIterable, Hashable {
    case threeByFour = "3×4"
    case threeByThree = "3×3"
    case fourByFour = "4×4"
    case fiveByFive = "5×5"

    var width: Int {
        switch self {
        case .threeByFour, .threeByThree: return 3
        case .fourByFour: return 4
        case .fiveByFive: return 5
        }
    }

    var height: Int {
        switch self {
        case .threeByThree: return 3
        case .threeByFour: return 4
        case .fourByFour: return 4
        case .fiveByFive: return 5
        }
    }

    init(width: Int, height: Int) {
        switch (width, height) {
        case (3, 3): self = .threeByThree
        case (4, 4): self = .fourByFour
        case (5, 5): self = .fiveByFive
        default:     self = .threeByFour
        }
    }
}

// MARK: - Mesh Gradient Editor

struct MeshGradientEditorView: View {
    @Binding var meshWidth: Int
    @Binding var meshHeight: Int
    @Binding var meshColors: [Color]
    @Binding var meshPointsX: [Double]
    @Binding var meshPointsY: [Double]


    private var selectedGridSize: MeshGridSize {
        MeshGridSize(width: meshWidth, height: meshHeight)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Grid size segmented picker
            Picker("Grid Size", selection: Binding(
                get: { selectedGridSize },
                set: { resizeGrid(to: $0) }
            )) {
                ForEach(MeshGridSize.allCases, id: \.self) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Live gradient preview with draggable dots
            GeometryReader { geo in
                ZStack {
                    gradientView(size: geo.size)
                        .cornerRadius(12)

                    ForEach(0..<min(meshPointsX.count, meshColors.count), id: \.self) { i in
                        draggableDot(index: i, size: geo.size)
                    }
                }
                .coordinateSpace(name: "gradientEditor")
            }
            .aspectRatio(CGFloat(meshWidth) / CGFloat(meshHeight), contentMode: .fit)
            .padding(.horizontal)
        }
    }

    // MARK: - Gradient Preview

    @ViewBuilder
    private func gradientView(size: CGSize) -> some View {
        if #available(macOS 15.0, *) {
            let count = meshWidth * meshHeight
            let safeColors = meshColors.count >= count ? meshColors : padded(meshColors, to: count)
            let safeX = meshPointsX.count >= count ? meshPointsX : GameTheme.evenPointsX(width: meshWidth, height: meshHeight)
            let safeY = meshPointsY.count >= count ? meshPointsY : GameTheme.evenPointsY(width: meshWidth, height: meshHeight)
            let points = zip(safeX, safeY).map { SIMD2<Float>(Float($0), Float($1)) }

            MeshGradient(
                width: meshWidth,
                height: meshHeight,
                points: points,
                colors: safeColors
            )
        } else {
            Rectangle().fill(meshColors.first ?? .gray)
        }
    }

    // MARK: - Draggable Dot

    @ViewBuilder
    private func draggableDot(index i: Int, size: CGSize) -> some View {
        ColorPicker("", selection: $meshColors[i], supportsOpacity: false)
            .labelsHidden()
            .position(
                x: meshPointsX[i] * size.width,
                y: meshPointsY[i] * size.height
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 5, coordinateSpace: .named("gradientEditor"))
                    .onChanged { value in
                        meshPointsX[i] = min(max(value.location.x / size.width, 0), 1)
                        meshPointsY[i] = min(max(value.location.y / size.height, 0), 1)
                    }
            )
    }

    // MARK: - Grid Resize

    private func resizeGrid(to newSize: MeshGridSize) {
        let oldWidth = meshWidth
        let oldHeight = meshHeight
        let oldColors = meshColors

        let newCount = newSize.width * newSize.height
        var newColors = Array(repeating: Color(hex: "808080"), count: newCount)

        // Preserve existing colors for overlapping (row, col) positions
        for row in 0..<min(oldHeight, newSize.height) {
            for col in 0..<min(oldWidth, newSize.width) {
                let oldIdx = row * oldWidth + col
                let newIdx = row * newSize.width + col
                if oldIdx < oldColors.count {
                    newColors[newIdx] = oldColors[oldIdx]
                }
            }
        }

        meshWidth = newSize.width
        meshHeight = newSize.height
        meshColors = newColors
        meshPointsX = GameTheme.evenPointsX(width: newSize.width, height: newSize.height)
        meshPointsY = GameTheme.evenPointsY(width: newSize.width, height: newSize.height)
    }

    // MARK: - Helpers

    private func padded(_ colors: [Color], to count: Int) -> [Color] {
        var result = colors
        while result.count < count { result.append(.gray) }
        return result
    }
}
