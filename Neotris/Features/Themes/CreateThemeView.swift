//
//  CreateThemeView.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import SwiftUI
import SwiftData

struct CreateThemeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var themeName: String = ""
    @State private var tetrominoColors: [Color] = GameTheme.defaultTetrominoHexColors.map { Color(hex: $0) }
    @State private var selectedTetrominoIndex: Int = 0
    @State private var showingBackground: Bool = false

    // Mesh gradient state
    @State private var meshWidth: Int = 3
    @State private var meshHeight: Int = 4
    @State private var meshColors: [Color] = GameTheme.defaultMeshHexColors.map { Color(hex: $0) }
    @State private var meshPointsX: [Double] = GameTheme.defaultMeshPointsX
    @State private var meshPointsY: [Double] = GameTheme.defaultMeshPointsY

    // iPhone-only: sheet for background editor
    @State private var showingBackgroundSheet: Bool = false
    
    var themesCount: Int

    var body: some View {
        Group {
#if os(iOS)
            IOSViewBuilder()
#else
            MacOSViewBuilder()
#endif
        }
#if os(iOS)
        .navigationTitle("Create Theme")
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    saveTheme()
                } label: {
#if os(iOS)
                    Image(systemName: "checkmark")
#else
                    Label("Create", systemImage: "checkmark")
#endif
                }
                    .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $showingBackgroundSheet) {
            NavigationStack {
                MeshGradientEditorView(
                    meshWidth: $meshWidth,
                    meshHeight: $meshHeight,
                    meshColors: $meshColors,
                    meshPointsX: $meshPointsX,
                    meshPointsY: $meshPointsY
                )
                .navigationTitle("Background")
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showingBackgroundSheet = false }
                    }
                }
            }
            .presentationDetents([.large])
        }
    }
    
#if os(iOS)
    @ViewBuilder
    private func IOSViewBuilder() -> some View {
        Form {
            Section {
                TextField("Theme Name", text: $themeName)
            }
            
            ForEach(TetrominoType.allCases.indices, id: \.self) { index in
                ColorPicker(selection: $tetrominoColors[index], supportsOpacity: false) {
                    HStack {
                        TetrominoShapeView(type: TetrominoType.allCases[index], color: tetrominoColors[index], cellSize: 10)
                            .frame(minWidth: 60)
                        Text(TetrominoType.allCases[index].rawValue).textCase(.uppercase)
                    }
                }
            }
            
            Section {
                Button {
                    showingBackgroundSheet = true
                } label: {
                    CustomLabel(leadingImageName: "paint.bucket.classic", trailingImageName: "chevron.up", title: "Background")
                }
            }
        }
    }
#endif
    
#if os(macOS)
    @ViewBuilder
    private func MacOSViewBuilder() -> some View {
        ScrollView {
            MacCustomSection {
                TextField("", text: $themeName, prompt: Text("Theme Name"))
            }
            .padding(.top)
            
            MacCustomSection(header: "Tetromino Colors") {
                ForEach(TetrominoType.allCases.indices, id: \.self) { index in
                    ColorPicker(selection: $tetrominoColors[index], supportsOpacity: false) {
                        HStack {
                            TetrominoShapeView(type: TetrominoType.allCases[index], color: tetrominoColors[index], cellSize: 10)
                                .frame(minWidth: 60)
                            Text(TetrominoType.allCases[index].rawValue).textCase(.uppercase)
                            Spacer()
                        }
                    }
                }
            }
            
            MacCustomSection {
                Button {
                    showingBackgroundSheet = true
                } label: {
                    CustomLabel(leadingImageName: "paint.bucket.classic", trailingImageName: "chevron.up", title: "Background")
                }
            }
            .padding(.bottom)
        }
    }
#endif

    // MARK: - Save
    private func saveTheme() {
        let name = themeName.isEmpty ? "Theme \(themesCount + 1)" : themeName
        let theme = GameTheme(name: name, themeIndex: themesCount)
        theme.tetrominoColors = tetrominoColors.map { $0.toHexString() }
        theme.meshWidth = meshWidth
        theme.meshHeight = meshHeight
        theme.meshColors = meshColors.map { $0.toHexString() }
        theme.meshPointsX = meshPointsX
        theme.meshPointsY = meshPointsY
        modelContext.insert(theme)
        viewModel.applyTheme(theme)
        dismiss()
    }
}

#Preview {
    #if os(iOS)
    NavigationView {
        CreateThemeView(themesCount: 2)
    }
    .environment(GameViewModel())
    #elseif os(macOS)
    CreateThemeView(themesCount: 2)
        .environment(GameViewModel())
    #endif
}
