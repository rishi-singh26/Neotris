//
//  GameSessionsListView.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

import SwiftUI
import SwiftData

struct GameSessionsListView: View {
    @EnvironmentObject var gameModel: TetrisGameModel
    @Environment(\.dismiss) var dismiss
    @Query private var gameSessions: [TetrisGameSession]
    
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
                
                Section(header: Text("Recent Games")) {
                    if gameSessions.isEmpty {
                        Text("No completed games yet")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(gameSessions.sorted(by: { $0.completionDate > $1.completionDate }).prefix(10)) { session in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(String(session.score)) points - Level \(String(session.level))")
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
                        }
                    }
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
    GameSessionsListView()
        .environmentObject(TetrisGameModel.shared)
}
