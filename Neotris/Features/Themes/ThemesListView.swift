//
//  ThemesListView.swift
//  Neotris
//
//  Created by Rishi Singh on 09/04/25.
//

import SwiftUI
import SwiftData
import TipKit

struct ThemesListView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(RemoteDataService.self) private var remoteDataService
    @Environment(\.modelContext) private var modelContext

    #if os(macOS)
    @State private var showAddThemeSheet: Bool = false
    #endif
    private let themesDetailTip = GameThemesDetailTip()

    @State private var themeToEdit: GameTheme? = nil
    @State private var themeToDelete: GameTheme? = nil
    @State private var customThemeToDuplicate: GameTheme? = nil
    @State private var builtInThemeToDuplicate: BuiltInTheme? = nil

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
        .confirmationDialog(
            "Delete \"\(themeToDelete?.name ?? "Theme")\"?",
            isPresented: Binding(
                get: { themeToDelete != nil },
                set: { if !$0 { themeToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let theme = themeToDelete {
                    deleteTheme(theme)
                    themeToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                themeToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(item: $themeToEdit) { theme in
#if os(iOS)
            NavigationStack {
                CreateThemeView(themesCount: themes.count, mode: .edit(theme))
            }
#else
            CreateThemeView(themesCount: themes.count, mode: .edit(theme))
#endif
        }
        .sheet(item: $customThemeToDuplicate) { theme in
#if os(iOS)
            NavigationStack {
                CreateThemeView(themesCount: themes.count, mode: .duplicateCustom(theme))
            }
#else
            CreateThemeView(themesCount: themes.count, mode: .duplicateCustom(theme))
#endif
        }
        .sheet(item: $builtInThemeToDuplicate) { theme in
#if os(iOS)
            NavigationStack {
                CreateThemeView(themesCount: themes.count, mode: .duplicateBuiltIn(theme))
            }
#else
            CreateThemeView(themesCount: themes.count, mode: .duplicateBuiltIn(theme))
#endif
        }
    }

    // MARK: - Platform Containers

#if os(iOS)
    @ViewBuilder
    private func IOSViewBuilder() -> some View {
        List {
            TipView(themesDetailTip)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            Section("Built-in") {
                ForEach(remoteDataService.builtInThemes) { theme in
                    BuiltInThemeRowBuilder(for: theme)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                builtInThemeToDuplicate = theme
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }
                            .tint(.orange)
                        }
                        .contextMenu {
                            Button {
                                builtInThemeToDuplicate = theme
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }
                        }
                }
            }

            Section("Custom Themes") {
                ForEach(themes) { theme in
                    ThemeRowBuilder(for: theme)
                        .swipeActions(edge: .leading) {
                            Button {
                                themeToEdit = theme
                            } label: {
                                Label("Edit", systemImage: "slider.horizontal.3")
                            }
                            .tint(.blue)
                            Button {
                                customThemeToDuplicate = theme
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                themeToDelete = theme
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button {
                                themeToEdit = theme
                            } label: {
                                Label("Edit", systemImage: "slider.horizontal.3")
                            }
                            Button {
                                customThemeToDuplicate = theme
                            } label: {
                                Label("Duplicate", systemImage: "doc.on.doc")
                            }
                            Divider()
                            Button(role: .destructive) {
                                themeToDelete = theme
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }

                NavigationLink {
                    CreateThemeView(themesCount: themes.count, mode: .create)
                } label: {
                    Label("Create New Theme", systemImage: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    CreateThemeView(themesCount: themes.count, mode: .create)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
#endif

#if os(macOS)
    @ViewBuilder
    private func MacOSViewBuilder() -> some View {
        ScrollView {
            TipView(themesDetailTip)
                .padding([.horizontal, .top])
            MacCustomSection(header: "Built-in") {
                VStack(spacing: 4) {
                    ForEach(remoteDataService.builtInThemes) { theme in
                        BuiltInThemeRowBuilder(for: theme)
                            .contextMenu {
                                Button {
                                    builtInThemeToDuplicate = theme
                                } label: {
                                    Label("Duplicate Theme", systemImage: "doc.on.doc")
                                }
                            }

                        if theme.id != remoteDataService.builtInThemes.last?.id {
                            Divider().padding(.vertical, 2)
                        }
                    }
                }
            }

            MacCustomSection(header: "Custom Themes") {
                VStack(spacing: 4) {
                    ForEach(themes) { theme in
                        ThemeRowBuilder(for: theme)
                            .contextMenu {
                                Button {
                                    themeToEdit = theme
                                } label: {
                                    Label("Edit Theme", systemImage: "slider.horizontal.3")
                                }
                                Button {
                                    customThemeToDuplicate = theme
                                } label: {
                                    Label("Duplicate Theme", systemImage: "doc.on.doc")
                                }
                                Divider()
                                Button(role: .destructive) {
                                    themeToDelete = theme
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
            CreateThemeView(themesCount: themes.count, mode: .create)
        }
    }
#endif

    // MARK: - Shared Row Builders

    @ViewBuilder
    private func BuiltInThemeRowBuilder(for theme: BuiltInTheme) -> some View {
        let isActive: Bool = theme.id == BuiltInTheme.default.id
            ? viewModel.activeThemeSnapshot == nil
            : viewModel.activeThemeSnapshot?.themeID == theme.id
        ThemeRowView(
            title: theme.name,
            subtitle: "Built-in",
            colors: theme.tetrominoColors.prefix(4).map { Color(hex: $0) },
            isActive: isActive,
            onSelect: {
                if theme.id == BuiltInTheme.default.id {
                    viewModel.clearTheme()
                } else {
                    viewModel.applyBuiltInTheme(theme)
                }
            },
            onDuplicate: { builtInThemeToDuplicate = theme }
        )
    }

    @ViewBuilder
    private func ThemeRowBuilder(for theme: GameTheme) -> some View {
        ThemeRowView(
            title: theme.name,
            subtitle: theme.creationDate.formatted(date: .abbreviated, time: .omitted),
            colors: theme.tetrominoColors.prefix(4).map { Color(hex: $0) },
            isActive: viewModel.activeThemeSnapshot?.themeID == theme.id.uuidString,
            onSelect: { viewModel.applyTheme(theme) },
            onEdit: { themeToEdit = theme },
            onDuplicate: { customThemeToDuplicate = theme },
            onDelete: { themeToDelete = theme }
        )
    }

    /// Unified row view for both built-in and custom theme rows.
    /// Platform layout differences (radio button vs tap-anywhere on iOS, ellipsis menu on macOS) are handled internally.
    @ViewBuilder
    private func ThemeRowView(
        title: String,
        subtitle: String,
        colors: [Color],
        isActive: Bool,
        onSelect: @escaping () -> Void,
        onEdit: (() -> Void)? = nil,
        onDuplicate: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) -> some View {
#if os(iOS)
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).fontWeight(.medium)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                themeColorDots(colors: colors)
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
#else
        HStack {
            HStack {
                Button(action: onSelect) {
                    Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isActive ? .blue : .primary)
                }
                .buttonStyle(.plain)
                .disabled(isActive)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .fontWeight(.medium)
                        .foregroundStyle(isActive ? .accent : Color.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            themeColorDots(colors: colors)
            if onEdit != nil || onDuplicate != nil || onDelete != nil {
                Menu {
                    if let onEdit {
                        Button("Edit", systemImage: "slider.horizontal.3") { onEdit() }
                    }
                    if let onDuplicate {
                        Button("Duplicate", systemImage: "doc.on.doc") { onDuplicate() }
                    }
                    if (onEdit != nil || onDuplicate != nil) && onDelete != nil {
                        Divider()
                    }
                    if let onDelete {
                        Button("Delete", systemImage: "trash", role: .destructive) { onDelete() }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuStyle(.borderlessButton)
            }
        }
#endif
    }

    // MARK: - Helpers

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

    private func deleteTheme(_ theme: GameTheme) {
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
        .environment(RemoteDataService())
        .modelContainer(for: [TetrisGameSession.self, GameTheme.self], inMemory: true)
    #else
    NavigationView {
        ThemesListView()
            .environment(GameViewModel())
            .environment(RemoteDataService())
    }
    .modelContainer(for: [TetrisGameSession.self, GameTheme.self], inMemory: true)
    #endif
}
