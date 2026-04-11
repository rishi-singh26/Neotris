//
//  ThemesListView.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import SwiftUI
import SwiftData

struct ThemesListView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.modelContext) private var modelContext
    
    #if os(macOS)
    @State private var showAddThemeSheet: Bool = false
    #endif

    @Query(sort: \GameTheme.creationDate) private var themes: [GameTheme]

    var body: some View {
        Group {
#if os(macOS)
            MacOSViewBuilder()
#else
            IOSViewBuilder()
#endif
        }
        .navigationTitle("Game Themes")
    }

#if os(iOS)
    @ViewBuilder
    private func IOSViewBuilder() -> some View {
        List {
            // Built-in default row
            Section {
                DefaultThemeRowBuilder()
            }

            // User-created themes
            Section("Custom Themes") {
                ForEach(themes) { theme in
                    ThemeRowBuilder(for: theme)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteTheme(theme)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteTheme(theme)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }

                NavigationLink {
                    CreateThemeView(themesCount: themes.count)
                } label: {
                    Label("Create New Theme", systemImage: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) { // Navigation bar trailing
                NavigationLink {
                    CreateThemeView(themesCount: themes.count)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    @ViewBuilder
    private func DefaultThemeRowBuilder() -> some View {
        let isActive = viewModel.activeThemeSnapshot == nil
        
        Button {
            viewModel.clearTheme()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Default")
                        .fontWeight(.medium)
                    Text("Built-in colors")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                themeColorDots(colors: GameTheme.defaultTetrominoHexColors.prefix(4).map { Color(hex: $0) })

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func ThemeRowBuilder(for theme: GameTheme) -> some View {
        let isActive = viewModel.activeThemeSnapshot?.themeID == theme.id.uuidString
        Button {
            viewModel.applyTheme(theme)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.name)
                        .fontWeight(.medium)
                    Text(theme.creationDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                themeColorDots(colors: theme.tetrominoColors.prefix(4).map { Color(hex: $0) })

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
#endif

#if os(macOS)
    @ViewBuilder
    private func MacOSViewBuilder() -> some View {
        ScrollView {
            MacCustomSection(header: "Built-in") {
                DefaultThemeRowBuilder()
            }

            MacCustomSection(header: "Custom Themes") {
                VStack(spacing: 4) {
                    ForEach(themes) { theme in
                        ThemeRowBuilder(for: theme)
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteTheme(theme)
                                } label: {
                                    Label("Delete Theme", systemImage: "trash")
                                }
                            }

                        if theme.id != themes.last?.id {
                            Divider().padding(.vertical, 2)
                        }
                    }

                    if !themes.isEmpty {
                        Divider().padding(.vertical, 2)
                    }

                    Button {
                        showAddThemeSheet = true
                    } label: {
                        Label("Create New Theme", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.bottom)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddThemeSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddThemeSheet) {
            CreateThemeView(themesCount: themes.count)
        }
    }
    
    @ViewBuilder
    private func DefaultThemeRowBuilder() -> some View {
        let isActive = viewModel.activeThemeSnapshot == nil
        
        HStack {
            HStack {
                Button {
                    viewModel.clearTheme()
                } label: {
                    Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isActive ? .blue : .primary)
                }
                .buttonStyle(.plain)
                .disabled(isActive)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Default")
                        .fontWeight(.medium)
                        .foregroundStyle(isActive ? .accent : Color.primary)
                    Text("Built-in colors")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            themeColorDots(colors: GameTheme.defaultTetrominoHexColors.prefix(4).map { Color(hex: $0) })
        }
    }

    @ViewBuilder
    private func ThemeRowBuilder(for theme: GameTheme) -> some View {
        let isActive = viewModel.activeThemeSnapshot?.themeID == theme.id.uuidString
        
        HStack {
            HStack {
                Button {
                    viewModel.applyTheme(theme)
                } label: {
                    Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isActive ? .blue : .primary)
                }
                .buttonStyle(.plain)
                .disabled(isActive)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.name)
                        .fontWeight(.medium)
                        .foregroundStyle(isActive ? .accent : Color.primary)
                    Text(theme.creationDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            themeColorDots(colors: theme.tetrominoColors.prefix(4).map { Color(hex: $0) })
            
            Menu {
                Button("Edit", systemImage: "slider.horizontal.2.square") {
                    deleteTheme(theme)
                }
                Divider()
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deleteTheme(theme)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
        }
    }
#endif
    
    /// Renders up to 4 small color circles as a quick visual preview.
    private func themeColorDots(colors: [Color]) -> some View {
        HStack(spacing: -4) {
            ForEach(colors.indices, id: \.self) { i in
                Circle()
                    .fill(colors[i])
                    .frame(width: 16, height: 16)
                    .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1))
            }
        }
        .padding(.trailing, 6)
    }

    // MARK: - Helpers

    private func deleteTheme(_ theme: GameTheme) {
        // If deleting the active theme, revert to default
        if viewModel.activeThemeSnapshot?.themeID == theme.id.uuidString {
            viewModel.clearTheme()
        }
        modelContext.delete(theme)
    }
}

#Preview {
#if os(macOS)
    ThemesListView()
        .environment(GameViewModel())
        .modelContainer(for: [TetrisGameSession.self, GameTheme.self], inMemory: true)
    #else
    NavigationView {
        ThemesListView()
            .environment(GameViewModel())
    }
    .modelContainer(for: [TetrisGameSession.self, GameTheme.self], inMemory: true)
    #endif
}
