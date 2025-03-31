//
//  ScoreBarView.swift
//  Neotris
//
//  Created by Rishi Singh on 29/03/25.
//

import SwiftUI

struct ScoreBarView: View {
    @EnvironmentObject var gameModel: TetrisGameModel
    let linesForNextLevel = 5
    
    var body: some View {
        let linesClearedInCurrentLevel = (gameModel.gameLevel.linesCleared % 5)
        if DeviceType.current == .iPhone {
            HStack {
                // New: Speed indicator
                //            Text("(\(gameModel.gameLevel.speedPercentage)% speed)")
                //                .font(.caption)
                //                .foregroundColor(speedColor())
                Spacer()
                VStack {
                    Text(String(gameModel.scoreSystem.highScore))
                        .font(.title3.bold())
                    Text("HIGH")
                        .font(.subheadline)
                }
                Spacer()
                VStack {
                    Text(String(gameModel.scoreSystem.score))
                        .font(.title3.bold())
                    Text("SCORE")
                        .font(.subheadline)
                }
                Spacer()
                VStack(spacing: 10) {
                    HStack {
                        Text("LEVEL")
                            .font(.subheadline)
                        Text(String(gameModel.gameLevel.level))
                            .font(.title3.bold())
                    }
                    
                    HStack(spacing: 4) {
                        ForEach(0..<linesForNextLevel, id: \.self) { i in
                            Rectangle()
                                .fill(i < (linesClearedInCurrentLevel) ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                            
                        }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: UIService.screenWidth - 10)
            .padding(.vertical)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(.horizontal, 10)
        } else {
            VStack {
                // New: Speed indicator
                //            Text("(\(gameModel.gameLevel.speedPercentage)% speed)")
                //                .font(.caption)
                //                .foregroundColor(speedColor())
                Spacer()
                VStack {
                    Text(String(gameModel.scoreSystem.highScore))
                        .font(.title.bold())
                    Text("HIGH")
                        .font(.subheadline)
                }
                Spacer()
                Spacer()
                VStack {
                    Text(String(gameModel.scoreSystem.score))
                        .font(.title.bold())
                    Text("SCORE")
                        .font(.subheadline)
                }
                Spacer()
                Spacer()
                VStack(spacing: 10) {
                    HStack {
                        Text("LEVEL")
                            .font(.subheadline)
                        Text(String(gameModel.gameLevel.level))
                            .font(.title.bold())
                    }
                    
                    HStack(spacing: 4) {
                        ForEach(0..<linesForNextLevel, id: \.self) { i in
                            Rectangle()
                                .fill(i < (linesClearedInCurrentLevel) ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                            
                        }
                    }
                }
                Spacer()
                Spacer()
                VStack(spacing: 10) {
                    Text("SPEED")
                        .font(.subheadline)
                    
                    SpeedMeterView(percentage: gameModel.gameLevel.speedPercentage)
                        .frame(width: 120, height: 10)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
            .padding(.horizontal, 25)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .frame(minHeight: 450, maxHeight: 450)
        }
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
