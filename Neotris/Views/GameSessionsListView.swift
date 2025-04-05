//
//  GameSessionsListView.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

import SwiftUI
import SwiftData

enum SortBy: String, Codable, CaseIterable {
    case startDate
    case endDate
    case score
    case level
    case playDuration
    
    var id: Self {
        self
    }
}

struct GameSessionsListView: View {
    var isWindow: Bool = false
    @EnvironmentObject var gameModel: TetrisGameModel
    @Environment(\.dismiss) var dismiss
    @State private var sortBy: SortBy = .startDate
    @State private var sortOrder: Bool = false
    
    var body: some View {
#if os(macOS)
        MacOSSessionListBuilder()
#else
        NavigationView {
            IOSSessionListBuilder()
        }
#endif
    }
    
#if os(macOS)
    @ViewBuilder
    func MacOSSessionListBuilder() -> some View {
        VStack {
            HStack {
                Text("Games")
                    .font(.largeTitle)
                Spacer()
                GameSortView()
                    .frame(maxWidth: 150)
            }
            .padding([.horizontal, .top], 30)
            ScrollView {
                MacCustomSection(header: "Current Game") {
                    CustomLabel(trailingText: String(gameModel.scoreSystem.score), title: "Score")
                    Divider()
                    CustomLabel(trailingText: String(gameModel.gameLevel.level), title: "Level")
                    Divider()
                    CustomLabel(trailingText: String(gameModel.gameLevel.linesCleared), title: "Lines Cleared")
                    Divider()
                    CustomLabel(trailingText: String(gameModel.scoreSystem.highScore), title: "High Score")
                    Divider()
                    HStack {
                        Text("Speed \(gameModel.gameLevel.speedPercentage)%")
                        Spacer()
                        SpeedMeterView(percentage: gameModel.gameLevel.speedPercentage)
                            .frame(width: 150, height: 10)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                MacCustomSection(header: "Recent Games", footer: "") {
                    GamesListView(sortBy: sortBy, sortOrder: sortOrder)
                }
            }
        }.frame(maxHeight: 650)
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
        .toolbar {
            if !isWindow {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
#endif
    
#if os(iOS)
    @ViewBuilder
    func IOSSessionListBuilder() -> some View {
        List {
            Section(header: Text("Current Game")) {
                LabeledContent("Score", value: String(gameModel.scoreSystem.score))
                LabeledContent("Level", value: String(gameModel.gameLevel.level))
                LabeledContent("Lines Cleared", value: "\(gameModel.gameLevel.linesCleared)")
                LabeledContent("High Score", value: "\(gameModel.scoreSystem.highScore)")
                HStack {
                    Text("Speed \(gameModel.gameLevel.speedPercentage)%")
                    Spacer()
                    SpeedMeterView(percentage: gameModel.gameLevel.speedPercentage)
                        .frame(width: 150, height: 10)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .listRowBackground(
                Rectangle()
                    .fill(.thinMaterial)
            )
            Section(header: HStack {
                Text("Recent Games")
                Spacer()
                GameSortView()
            }) {
                GamesListView(sortBy: sortBy, sortOrder: sortOrder)
            }
            .listRowBackground(
                Rectangle()
                    .fill(.thinMaterial)
            )
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Games")
        .toolbar(content: {
            ToolbarItem {
                Button {
                    dismiss()
                } label: {
                    Label("Dismiss", systemImage: "xmark.circle.fill")
                }
                
            }
        })
    }
#endif
    
    @ViewBuilder
    func GameSortView() -> some View {
        Menu {
            Picker("Sort By", selection: $sortBy) {
                Text("Start Date").tag(SortBy.startDate)
                Text("End Date").tag(SortBy.endDate)
                Text("Score").tag(SortBy.score)
                Text("Level").tag(SortBy.level)
                Text("Game Duration").tag(SortBy.playDuration)
            }
            .pickerStyle(.inline)
            Divider()
            Picker("Sort Order", selection: $sortOrder) {
                Text("Ascending").tag(true)
                Text("Descending").tag(false)
            }
            .pickerStyle(.inline)
        } label: {
            Label("Sort", systemImage: "chevron.compact.up.chevron.compact.down")
                .font(.footnote)
        }
    }
}

struct GamesListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \TetrisGameSession.creationDate, order: .reverse) private var gameSessions: [TetrisGameSession]
    @State private var showDeleteConfirmation = false
    @State private var selectedSessionForDeletion: TetrisGameSession?

    init(sortBy: SortBy, sortOrder: Bool) {
        
        let sortDescriptors: [SortDescriptor<TetrisGameSession>] = switch sortBy {
        case .startDate:
            [SortDescriptor(\TetrisGameSession.creationDate, order: sortOrder ? .forward : .reverse)]
        case .endDate:
            [SortDescriptor(\TetrisGameSession.completionDate, order: sortOrder ? .forward : .reverse)]
        case .score:
            [SortDescriptor(\TetrisGameSession.score, order: sortOrder ? .forward : .reverse)]
        case .level:
            [SortDescriptor(\TetrisGameSession.level, order: sortOrder ? .forward : .reverse)]
        case .playDuration:
            [SortDescriptor(\TetrisGameSession.playDuration, order: sortOrder ? .forward : .reverse)]
        }
        
        _gameSessions = Query(sort: sortDescriptors)
    }
    
    var body: some View {
        if gameSessions.isEmpty {
            Text("No completed games yet")
                .foregroundColor(.gray)
        } else {
            ForEach(gameSessions) { session in
                VStack {
                    SessionTileBuilder(session: session)
#if os(macOS)
                    if gameSessions.last?.id != session.id {
                        Divider()
                    }
#endif
                }

#if os(iOS)
                .swipeActions(edge: .trailing) {
                    Button {
                        showDeleteConfirmation(session: session)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
#endif
                .contextMenu {
                    Button(role: .destructive, action: {
                        showDeleteConfirmation(session: session)
                    }, label: {
                        Label("Delete", systemImage: "trash")
                    })
                }
            }
            .confirmationDialog("Alert", isPresented: $showDeleteConfirmation, actions: {
                Button("Delete", role: .destructive) {
                    deleteGame()
                }
            }) {
                Text("Are you sure you want to delete this game session?")
            }
        }
    }
    
    @ViewBuilder
    func SessionTileBuilder(session: TetrisGameSession) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(String(session.score)) Points - Level \(String(session.level))")
                    .font(.headline)
                Text("\(session.completionDate, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            HStack(spacing: 10) {
                VStack(alignment: .trailing) {
                    Text(String(session.linesCleared))
                        .font(.headline)
                    Text("Lines Cleared")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
#if os(macOS)
                Button {
                    showDeleteConfirmation(session: session)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(PlainButtonStyle())
#endif

            }
        }
    }
    
    func showDeleteConfirmation(session: TetrisGameSession) {
        selectedSessionForDeletion = session
        showDeleteConfirmation.toggle()
    }
    
    func deleteGame() {
        guard let session = selectedSessionForDeletion else { return }
        withAnimation(.linear) {
            modelContext.delete(session)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    TetrisGameView()
        .environmentObject(TetrisGameModel.shared)
}
