//
//  WinnersSummaryScreen.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI
import Combine

struct WinnersSummaryScreen: View {
    @ObservedObject var vm: DrawViewModel
    @State private var showConfetti = true
    @State private var copied = false

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 24) {
                GlowingText(text: vm.congratulationsTitle, size: 44, color: .white, glowColor: .purple)

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(groupedPrizeNames(), id: \.self) { prizeName in
                            let wins = vm.winners.filter { $0.prizeName == prizeName }
                                .sorted { $0.sequenceIndex < $1.sequenceIndex }
                            VStack(alignment: .leading, spacing: 6) {
                                Text(prizeName)
                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(wins.map { "\($0.number)" }.joined(separator: "، "))
                                    .font(.system(size: 20, weight: .regular, design: .rounded))
                                    .foregroundStyle(Color.orange)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: 900)

                HStack(spacing: 16) {
                    Button {
                        vm.restartSystem()
                    } label: {
                        Text(vm.restartText)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 22)
                            .background(.white.opacity(0.1))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button {
                        vm.copyResultsToPasteboard()
                        withAnimation(.easeInOut) {
                            copied = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeInOut) { copied = false }
                        }
                    } label: {
                        Text(vm.exportText)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 22)
                            .background(
                                LinearGradient(colors: [Color.purple, Color.blue],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()

            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
            }

            if copied {
                Text("تم النسخ")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.25), lineWidth: 1))
                    .foregroundStyle(.white)
                    .padding(.top, 40)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Optional: confetti stops after some time
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                withAnimation(.easeInOut) { showConfetti = false }
            }
        }
    }

    private func groupedPrizeNames() -> [String] {
        let ordered = vm.expandedPrizes.map { $0.name }
        let unique = Array(NSOrderedSet(array: ordered)) as? [String] ?? ordered
        return unique
    }
}
