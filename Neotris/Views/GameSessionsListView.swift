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
    case linesCleared
    case playDuration
    
    var id: Self {
        self
    }
}

struct GameSessionsListView: View {
    @EnvironmentObject var gameModel: TetrisGameModel
    @Environment(\.dismiss) var dismiss
    @State private var sortBy: SortBy = .startDate
    @State private var sortOrder: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Current Game")) {
                    LabeledContent("Score", value: "\(gameModel.scoreSystem.score)")
                    LabeledContent("Level", value: "\(gameModel.gameLevel.level)")
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
//                    Menu {
//                        Picker("Sort By", selection: $sortBy) {
//                            Text("Start Date").tag(SortBy.startDate)
//                            Text("End Date").tag(SortBy.endDate)
//                            Text("Score").tag(SortBy.score)
//                            Text("Level").tag(SortBy.level)
//                            Text("Lines Cleared").tag(SortBy.linesCleared)
//                            Text("Game Duration").tag(SortBy.playDuration)
//                        }
//                        Divider()
//                        Picker("Sort Order", selection: $sortOrder) {
//                            Text("Ascending").tag(true)
//                            Text("Descending").tag(false)
//                        }
//                    } label: {
//                        Label("Sort", systemImage: "chevron.compact.up.chevron.compact.down")
//                            .font(.footnote)
//                    }
                }) {
//                    GamesListView(sortBy: sortBy, sortOrder: sortOrder)
                    GamesListView()
                }
                .listRowBackground(
                    Rectangle()
                        .fill(.thinMaterial)
                )
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Games")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct GamesListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \TetrisGameSession.creationDate, order: .reverse) private var gameSessions: [TetrisGameSession]
    @State private var showDeleteConfirmation = false
    @State private var selectedSessionForDeletion: TetrisGameSession?
            
//    init(sortBy: SortBy, sortOrder: Bool) {
//        
//        let sortDescriptors: [SortDescriptor<TetrisGameSession>] = switch sortBy {
//        case .startDate:
//            [SortDescriptor(\TetrisGameSession.creationDate, order: sortOrder ? .forward : .reverse)]
//        case .endDate:
//            [SortDescriptor(\TetrisGameSession.completionDate, order: sortOrder ? .forward : .reverse)]
//        case .score:
//            [SortDescriptor(\TetrisGameSession.score, order: sortOrder ? .forward : .reverse)]
//        case .level:
//            [SortDescriptor(\TetrisGameSession.level, order: sortOrder ? .forward : .reverse)]
//        case .linesCleared:
//            [SortDescriptor(\TetrisGameSession.linesCleared, order: sortOrder ? .forward : .reverse)]
//        case .playDuration:
//            [SortDescriptor(\TetrisGameSession.playDuration, order: sortOrder ? .forward : .reverse)]
//        }
//        
//        _gameSessions = Query(sort: sortDescriptors)
//    }
    
    var body: some View {
        if gameSessions.isEmpty {
            Text("No completed games yet")
                .foregroundColor(.gray)
        } else {
            ForEach(gameSessions.sorted(by: { $0.completionDate > $1.completionDate }).prefix(10)) { session in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(String(session.score)) Points - Level \(String(session.level))")
                            .font(.headline)
                        Text("\(session.completionDate, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(String(session.linesCleared))
                            .font(.headline)
                        Text("Lines Cleared")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        selectedSessionForDeletion = session
                        showDeleteConfirmation.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                // YOUR ALERT CONTENT IN VIEW FORMAT
                CustomDialogTwo(
                    title: "Alert",
                    content: "Are you sure you want to delete this game session?",
                    button1: .init(content: "Delete", tint: .blue, foreground: .white, role: .destructive, action: { _ in
                        showDeleteConfirmation = false
                        deleteGame()
                    }),
                    button2: .init(content: "Reset", tint: .red, foreground: .white, action: { _ in
                        showDeleteConfirmation = false
                    }),
                    addsTextField: true,
                    textFieldHint: ""
                )
                // Since it's using "if" condition to add view we can use SwiftUI Transition
                .transition(.scale.combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: showDeleteConfirmation)
                // .transition(.blurReplace.combined(with: .push(from: .bottom)))
                // .transition(.move(edge: .top).combined(with: .opacity))
            } background: {
                // YOUR BACKGROUND CONTENT IN VIEW FORMAT
                // Rectangle().fill(.primary.opacity (0.35))
            }
            .confirmationDialog(
                "Are you sure you want to delete this game session?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteGame()
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    func deleteGame() {
        guard let session = selectedSessionForDeletion else { return }
        modelContext.delete(session)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct SpeedMeterView: View {
    let percentage: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(meterColor)
                    .frame(width: CGFloat(percentage) / 100 * geometry.size.width)
                    .cornerRadius(2)
            }
        }
    }
    
    var meterColor: Color {
        switch percentage {
        case 0..<30: return .green
        case 30..<70: return .yellow
        default: return .red
        }
    }
}

#Preview {
    TetrisGameView()
        .environmentObject(TetrisGameModel.shared)
}
