//
//  GameInstructionsView.swift
//  Neotris
//
//  Created by Rishi Singh on 30/03/25.
//

import SwiftUI

struct GameInstructionsView: View {
    @Environment(\.dismiss) var dismiss
        
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("How to Play")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Tetris is a classic puzzle game where you arrange falling blocks to create complete lines.")
                        
                        Text("Game Controls:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("• Swipe left/right: Move piece horizontally")
                            Text("• Swipe down: Move piece down faster")
                            Text("• Tap screen: Rotate piece")
                            Text("• Double tap: Hard drop (piece falls immediately)")
                        }
                        
                        Text("Keyboard Controls (iPad/Mac):")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("• Arrow keys: Move piece")
                            Text("• Up arrow: Rotate piece")
                            Text("• Space: Hard drop")
                            Text("• P: Pause game")
                        }
                    }
                    
                    Group {
                        Text("Scoring:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("• 1 line: 40 × level")
                            Text("• 2 lines: 100 × level")
                            Text("• 3 lines: 300 × level")
                            Text("• 4 lines: 1200 × level")
                        }
                        
                        Text("Tips:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("• Use the ghost piece (transparent outline) to see where your piece will land")
                            Text("• Plan ahead by checking the Next piece display")
                            Text("• Try to keep the stack low and even")
                            Text("• Save I-pieces for Tetris clears (4 lines)")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    GameInstructionsView()
}
