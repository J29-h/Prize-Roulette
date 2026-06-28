//
//  CountdownScreen.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI
import AVFoundation

struct CountdownScreen: View {
    @ObservedObject var vm: DrawViewModel
    @State private var index: Int = 0
    @State private var scale: CGFloat = 0.6
    @State private var glow: Double = 0.2

    var body: some View {
        VStack(spacing: 24) {
            if let prize = vm.currentPrize {
                Text("الجائزة الحالية")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                GlowingText(text: prize.name, size: 32, color: .white, glowColor: .purple)
            }

            GlowingText(text: vm.countdownNumbers[index], size: 160, color: .white, glowColor: .purple)
                .scaleEffect(scale)
                .opacity(0.9)
                .onAppear {
                    performCountdown()
                }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }

    private func performCountdown() {
        // Mock sound placeholder using haptics
        playTick()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            scale = 1.1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale = 0.9
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if index < vm.countdownNumbers.count - 1 {
                index += 1
                performCountdown()
            } else {
                // Completed countdown
                vm.proceedToDrawing()
            }
        }
    }

    private func playTick() {
        // Haptic as a placeholder "sound"
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        #endif
    }
}
