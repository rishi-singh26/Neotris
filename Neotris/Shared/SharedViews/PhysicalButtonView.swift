//
//  PhysicalButtonView.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

//import SwiftUI
//
//struct PhysicalButtonView: View {
//    static let smallButtonSize = CGSize(width: 40, height: 40)
//    static let mediumButtonSize = CGSize(width: 60, height: 60)
//    static let largeButtonSize = CGSize(width: 80, height: 80)
//    
//    @State private var isPressed = false
//    
//    var backgroundColor: Color?
//    var foregroundColor: Color?
//    var size: CGSize?
//    var iconName: String
//    var onPressed: () -> Void
//    
//    // Create a haptic feedback generator
//    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
//    
//    var body: some View {
//        Button(action: {
//            onPressed()
//            #if os(iOS)
//            hapticImpact.prepare()
//            hapticImpact.impactOccurred()
//            #endif
//        }) {
//            Image(systemName: iconName)
//                .font(.system(size: (size?.width ?? 48) / 2, weight: .semibold))
//                .foregroundColor(.white)
//                .frame(width: size?.width ?? 60, height: size?.height ?? 60)
//                .background(
//                    ZStack {
//                        // Shadow for "raised" appearance
//                        Circle()
//                            .fill(backgroundColor ?? Color.blue)
//                            .shadow(color: .black.opacity(0.2), radius: isPressed ? 2 : 5, x: 0, y: isPressed ? 1 : 3)
//                        
//                        // Highlight at the top
//                        Circle()
//                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                            .padding(1)
//                            .opacity(isPressed ? 0.2 : 0.8)
//                        
//                        // Inner shadow for pressed state
//                        if isPressed {
//                            Circle()
//                                .stroke(Color.black.opacity(0.2), lineWidth: 2)
//                                .blur(radius: 2)
//                                .padding(1)
//                        }
//                    }
//                )
//                .offset(y: isPressed ? 2 : 0)
//                .scaleEffect(isPressed ? 0.95 : 1)
//                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .simultaneousGesture(
//            DragGesture(minimumDistance: 0)
//                .onChanged { _ in
//                    isPressed = true
//                }
//                .onEnded { _ in
//                    isPressed = false
//                }
//        )
//    }
//}
//
//#Preview {
//    PhysicalButtonView(backgroundColor: .green, iconName: "arrow.left") {
//        print("Pressed")
//    }
//}
