//
//  PrizeResultScreen.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI
import Combine

struct PrizeResultScreen: View {
    @ObservedObject var vm: DrawViewModel
    @State private var showGlow = false

    var body: some View {
        VStack(spacing: 20) {
            if let prize = vm.currentPrize {
                HStack(spacing: 16) {
                    Image(systemName: prize.symbolName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    GlowingText(text: prize.name, size: 34, color: .white, glowColor: .purple)
                    Spacer()
                }
            }

            Spacer()

            Text(vm.winningNumberLabel)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            GlowingText(text: vm.largeNumberString, size: 160, color: .white, glowColor: .orange)
                .scaleEffect(showGlow ? 1.08 : 1.0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        showGlow = true
                    }
                    playHit()
                }

            Spacer()

            HStack(spacing: 16) {
                Button {
                    vm.confirmWinner()
                    playConfirm()
                } label: {
                    Text(vm.confirmWinnerText)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(Color.orange.gradient)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.orange.opacity(0.7), radius: 12, x: 0, y: 8)
                }
                .buttonStyle(.plain)

                Button {
                    vm.redrawForCurrentPrize()
                    playRedraw()
                } label: {
                    Text(vm.redrawText)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(.white.opacity(0.08))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }

    private func playHit() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    private func playConfirm() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 1.0)
        #endif
    }

    private func playRedraw() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
}
