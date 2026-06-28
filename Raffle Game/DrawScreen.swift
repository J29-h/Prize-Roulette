//
//  DrawScreen.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI
import Combine

struct DrawScreen: View {
    @ObservedObject var vm: DrawViewModel

    // Active-card hero animation
    @State private var heroActive: Bool = false
    @State private var heroScale: CGFloat = 1.0

    // Landing pulse for the large number when it locks
    @State private var landingPulse: CGFloat = 1.0

    // Summary overlay state
    @State private var showSummaryOverlay: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                // Top: gift grid
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 24) {
                        ForEach(Array(vm.expandedPrizes.enumerated()), id: \.offset) { idx, prize in
                            UnifiedGiftCard(
                                prize: prize,
                                index: idx,
                                isActive: idx == vm.currentIndex,
                                heroScale: heroScale,
                                heroActive: heroActive,
                                confirmedNumber: confirmedWinnerNumber(forIndex: idx),
                                assetName: assetNameFor(prize: prize)
                            )
                            .opacity(cardOpacity(for: idx))
                            .animation(.easeInOut(duration: 0.25), value: heroActive)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .frame(maxWidth: 1400, alignment: .center) // optional cap for huge screens
                }

                // Middle: large shared rolling number area
                Group {
                    if vm.isRolling || vm.selectedNumber != nil || vm.rollingNumber != 0 {
                        let display = vm.selectedNumber ?? vm.rollingNumber
                        GlowingText(
                            text: "\(display)",
                            size: 136, // larger
                            color: .white,
                            glowColor: vm.selectedNumber != nil ? .orange : .purple
                        )
                        .scaleEffect(vm.selectedNumber != nil ? landingPulse : 1.0)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.12), value: display)
                        .onChange(of: vm.selectedNumber) { newValue in
                            if newValue != nil {
                                // Lock-in pulse
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                                    landingPulse = 1.08
                                }
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.08)) {
                                    landingPulse = 1.0
                                }
                            }
                        }
                        .padding(.top, 6)
                    }
                }
                .frame(minHeight: 160) // reserve slightly more space

                // Bottom: buttons area
                VStack(spacing: 16) {
                    if vm.selectedNumber == nil {
                        LargeCTAButton(title: vm.startDrawText) {
                            startHeroIfNeeded()
                            vm.startRolling()
                            playRollHaptic()
                        }
                        .disabled(vm.isRolling)
                        .opacity(vm.isRolling ? 0.6 : 1.0)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        HStack(spacing: 18) {
                            Button {
                                vm.confirmWinner()
                                endHero()
                                if vm.drawState == .summary {
                                    withAnimation(.easeInOut) { showSummaryOverlay = true }
                                }
                            } label: {
                                Text(vm.confirmWinnerText)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 26)
                                    .background(Color.orange.gradient)
                                    .foregroundStyle(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: Color.orange.opacity(0.7), radius: 14, x: 0, y: 8)
                            }
                            .buttonStyle(.plain)

                            Button {
                                vm.redrawForCurrentPrize()
                            } label: {
                                Text(vm.redrawText)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 26)
                                    .background(.white.opacity(0.1))
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .onChange(of: vm.isRolling) { rolling in
                if rolling {
                    startHeroIfNeeded()
                } else {
                    endHero()
                }
            }
            .onChange(of: vm.selectedNumber) { newValue in
                if newValue != nil {
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.6)) {
                        heroScale = 1.06
                    }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.08)) {
                        heroScale = 1.0
                    }
                }
            }

            if showSummaryOverlay || vm.drawState == .summary {
                SummaryOverlay(vm: vm, dismiss: {
                    withAnimation(.easeInOut) { showSummaryOverlay = false }
                })
                .transition(.opacity)
                .ignoresSafeArea()
            }
        }
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 260), spacing: 24, alignment: .top), count: 5)
    }

    private func cardOpacity(for idx: Int) -> Double {
        if (vm.isRolling || vm.selectedNumber != nil) && idx != vm.currentIndex {
            return 0.45
        }
        return 1.0
    }

    private func startHeroIfNeeded() {
        guard !heroActive else { return }
        heroActive = true
        withAnimation(.spring(response: 0.36, dampingFraction: 0.65)) {
            heroScale = 1.2
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.85).delay(0.2)) {
            heroScale = 1.02
        }
    }

    private func endHero() {
        withAnimation(.easeInOut(duration: 0.25)) {
            heroScale = 1.0
            heroActive = false
        }
    }

    private func playRollHaptic() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }

    private func confirmedWinnerNumber(forIndex index: Int) -> Int? {
        guard vm.expandedPrizes.indices.contains(index) else { return nil }
        let name = vm.expandedPrizes[index].name
        let allForName = vm.winners
            .filter { $0.prizeName == name }
            .sorted { $0.sequenceIndex < $1.sequenceIndex }
        let unitSequence = vm.expandedPrizes.prefix(index + 1).filter { $0.name == name }.count
        return allForName.first(where: { $0.sequenceIndex == unitSequence })?.number
    }

    private func assetNameFor(prize: Prize) -> String {
        switch prize.name {
        case "Apple MacBook Air":
            return "Macbook"
        case "Samsung Galaxy S25 Ultra":
            return "Galaxy"
        case "Apple iPhone 17 Pro":
            return "iPhone"
        case "قسيمة شراء 2000":
            return "Cupon1"
        case "قسيمة شراء 1500":
            return "Cupon2"
        default:
            return prize.symbolName
        }
    }
}

// MARK: - Gift Card

private struct UnifiedGiftCard: View {
    let prize: Prize
    let index: Int
    let isActive: Bool
    let heroScale: CGFloat
    let heroActive: Bool
    let confirmedNumber: Int?
    let assetName: String

    @State private var lockPulse: CGFloat = 1.0

    var body: some View {
        // Tight vertical stack so the name sits directly under the image
        VStack(spacing: 10) {
            ZStack {
                if isActive && heroActive {
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.orange.opacity(0.75), location: 0.0),
                            .init(color: Color.orange.opacity(0.50), location: 0.25),
                            .init(color: Color.orange.opacity(0.28), location: 0.55),
                            .init(color: Color.orange.opacity(0.0),  location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 8,
                        endRadius: 540
                    )
                    .scaleEffect(1.2)
                    .padding(100)
                    .blur(radius: 56)
                    .blendMode(.plusLighter)
                }

                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .shadow(color: (isActive ? Color.orange : Color.purple).opacity(0.6),
                            radius: isActive ? 22 : 12, x: 0, y: isActive ? 12 : 6)
                    .shadow(color: (isActive ? Color.orange : Color.purple).opacity(0.42),
                            radius: isActive ? 44 : 22, x: 0, y: 0)
                    .shadow(color: (isActive ? Color.orange : Color.purple).opacity(0.24),
                            radius: isActive ? 70 : 34, x: 0, y: 0)
                    .padding(6)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .scaleEffect(isActive ? heroScale : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: heroScale)

            // Name directly under image
            Text(prize.name)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.97))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.85)

            // Winner badge space (kept below name)
            ZStack {
                if let confirmed = confirmedNumber {
                    FrozenBadge(number: confirmed)
                        .scaleEffect(lockPulse)
                        .onAppear {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                lockPulse = 1.04
                            }
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.9).delay(0.06)) {
                                lockPulse = 1.0
                            }
                        }
                } else {
                    Color.clear.frame(height: 0)
                }
            }
            .frame(height: 42)
        }
        // Do NOT force a tall vertical frame; let the card hug its content
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

private struct FrozenBadge: View {
    let number: Int
    var body: some View {
        Text("\(number)")
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: Color.orange.opacity(0.78), radius: 14)
            .shadow(color: Color.orange.opacity(0.78), radius: 22)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
}
