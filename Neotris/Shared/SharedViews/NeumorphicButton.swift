//
//  NeumorphicButton.swift
//  Neotris
//
//  Created by Rishi Singh on 02/03/25.
//

//import SwiftUI
//
//struct NeumorphicButton: View {
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
//        }) {
//            Image(systemName: iconName)
//                .font(.system(size: 40))
//                .foregroundColor(foregroundColor ?? .white)
//                .frame(width: size?.width ?? 100, height: size?.height ?? 100)
//                .background(
//                    Circle()
//                        .fill(Color(backgroundColor ?? .gray))
//                        .shadow(color: Color.white.opacity(0.8), radius: 10, x: -15, y: -15)
//                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
//                )
//                .overlay(
//                    Circle()
//                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
//                )
//                .scaleEffect(isPressed ? 0.9 : 1.0) // Press effect
//                .animation(.spring(), value: isPressed)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .simultaneousGesture(
//            DragGesture(minimumDistance: 0)
//                .onChanged { _ in
//                    isPressed = true
//#if os(iOS)
//                    hapticImpact.prepare()
//                    hapticImpact.impactOccurred()
//#endif
//                }
//                .onEnded { _ in
//                    isPressed = false
//                }
//        )
//    }
//}
//
//#Preview {
//    NeumorphicButton(iconName: "square.and.arrow.up.badge.clock") {
//        print("Hello")
//    }
//}
