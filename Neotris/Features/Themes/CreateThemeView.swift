//
//  CreateThemeView.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import SwiftUI
import SwiftData

/// Describes how the CreateThemeView was opened.
enum ThemeCreationMode {
    case create
    case edit(GameTheme)
    case duplicateCustom(GameTheme)
    case duplicateBuiltIn(BuiltInTheme)
}

struct CreateThemeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var themeName: String
    @State private var tetrominoColors: [Color]
    @State private var selectedTetrominoIndex: Int = 0
    @State private var showingBackground: Bool = false

    // Mesh gradient state
    @State private var meshWidth: Int
    @State private var meshHeight: Int
    @State private var meshColors: [Color]
    @State private var meshPointsX: [Double]
    @State private var meshPointsY: [Double]

    // iPhone-only: sheet for background editor
    @State private var showingBackgroundSheet: Bool = false

    var themesCount: Int
    var mode: ThemeCreationMode

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    init(themesCount: Int, mode: ThemeCreationMode = .create) {
        self.themesCount = themesCount
        self.mode = mode

        switch mode {
        case .create:
            _themeName       = State(initialValue: "")
            _tetrominoColors = State(initialValue: GameTheme.defaultTetrominoHexColors.map { Color(hex: $0) })
            _meshWidth       = State(initialValue: 3)
            _meshHeight      = State(initialValue: 4)
            _meshColors      = State(initialValue: GameTheme.defaultMeshHexColors.map { Color(hex: $0) })
            _meshPointsX     = State(initialValue: GameTheme.defaultMeshPointsX)
            _meshPointsY     = State(initialValue: GameTheme.defaultMeshPointsY)

        case .edit(let theme):
            _themeName       = State(initialValue: theme.name)
            _tetrominoColors = State(initialValue: theme.tetrominoColors.map { Color(hex: $0) })
            _meshWidth       = State(initialValue: theme.meshWidth)
            _meshHeight      = State(initialValue: theme.meshHeight)
            _meshColors      = State(initialValue: theme.meshColors.map { Color(hex: $0) })
            _meshPointsX     = State(initialValue: theme.meshPointsX)
            _meshPointsY     = State(initialValue: theme.meshPointsY)

        case .duplicateCustom(let theme):
            _themeName       = State(initialValue: "\(theme.name) Copy")
            _tetrominoColors = State(initialValue: theme.tetrominoColors.map { Color(hex: $0) })
            _meshWidth       = State(initialValue: theme.meshWidth)
            _meshHeight      = State(initialValue: theme.meshHeight)
            _meshColors      = State(initialValue: theme.meshColors.map { Color(hex: $0) })
            _meshPointsX     = State(initialValue: theme.meshPointsX)
            _meshPointsY     = State(initialValue: theme.meshPointsY)

        case .duplicateBuiltIn(let builtIn):
            _themeName       = State(initialValue: "\(builtIn.name) Copy")
            _tetrominoColors = State(initialValue: builtIn.tetrominoColors.map { Color(hex: $0) })
            _meshWidth       = State(initialValue: builtIn.meshWidth)
            _meshHeight      = State(initialValue: builtIn.meshHeight)
            _meshColors      = State(initialValue: builtIn.meshColors.map { Color(hex: $0) })
            _meshPointsX     = State(initialValue: builtIn.meshPointsX)
            _meshPointsY     = State(initialValue: builtIn.meshPointsY)
        }
    }

    var body: some View {
        Group {
#if os(iOS)
            IOSViewBuilder()
#else
            MacOSViewBuilder()
#endif
        }
#if os(iOS)
        .navigationTitle(isEditing ? "Edit Theme" : "Create Theme")
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
                    Label(isEditing ? "Save" : "Create", systemImage: "checkmark")
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
        if case .edit(let theme) = mode {
            // Edit mode — mutate the SwiftData object directly (auto-persisted)
            theme.name            = themeName.isEmpty ? theme.name : themeName
            theme.tetrominoColors = tetrominoColors.map { $0.toHexString() }
            theme.meshWidth       = meshWidth
            theme.meshHeight      = meshHeight
            theme.meshColors      = meshColors.map { $0.toHexString() }
            theme.meshPointsX     = meshPointsX
            theme.meshPointsY     = meshPointsY
            // Refresh active snapshot if this was the active theme
            if viewModel.activeThemeSnapshot?.themeID == theme.id.uuidString {
                viewModel.applyTheme(theme)
            }
        } else {
            // Create / duplicate modes — insert a new GameTheme
            let name = themeName.isEmpty ? "Theme \(themesCount + 1)" : themeName
            let theme = GameTheme(name: name, themeIndex: themesCount)
            theme.tetrominoColors = tetrominoColors.map { $0.toHexString() }
            theme.meshWidth       = meshWidth
            theme.meshHeight      = meshHeight
            theme.meshColors      = meshColors.map { $0.toHexString() }
            theme.meshPointsX     = meshPointsX
            theme.meshPointsY     = meshPointsY
            modelContext.insert(theme)
            viewModel.applyTheme(theme)
        }
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
