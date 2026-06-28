//
//  RollingNumbersView.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI

// Displays a large rolling number; when locked, adds glow/shake and smooth reveal
struct RollingNumbersView: View {
    var number: Int
    var isLocked: Bool

    @State private var shake: CGFloat = 0

    var body: some View {
        ZStack {
            if !isLocked {
                // Rolling state
                Text("\(number)")
                    .font(.system(size: 140, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.purple.opacity(0.6), radius: 12, x: 0, y: 0)
                    .shadow(color: Color.purple.opacity(0.6), radius: 24, x: 0, y: 0)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: number)
                    .transition(.identity) // no special transition while rolling
            } else {
                // Locked (final) state with smooth appear
                Text("\(number)")
                    .font(.system(size: 140, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.orange.opacity(0.6), radius: 12, x: 0, y: 0)
                    .shadow(color: Color.orange.opacity(0.6), radius: 24, x: 0, y: 0)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: number)
                    // Smooth reveal: fade + scale
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.85, anchor: .center)
                                .combined(with: .opacity),
                            removal: .opacity
                        )
                    )
            }
        }
        // Animate when locked state changes (applies the transition)
        .animation(.easeInOut, value: isLocked)
        // Keep existing effects
        .scaleEffect(isLocked ? 1.1 : 1.0)
        .modifier(ShakeEffect(shakes: isLocked ? 2 : 0, animatableData: shake))
        .onChange(of: isLocked) { locked in
            if locked {
                withAnimation(.interpolatingSpring(stiffness: 200, damping: 5)) {
                    shake += 1
                }
            }
        }
        .padding()
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 10 * sin(animatableData * .pi * CGFloat(shakes))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
