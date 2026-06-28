//
//  GiftsShowcaseScreen.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI

struct GiftsShowcaseScreen: View {
    @ObservedObject var vm: DrawViewModel

    @State private var phase: Phase = .opening
    @State private var currentIndex: Int = -1
    @State private var showCard: Bool = false
    @State private var showName: Bool = false
    @State private var showFinalGrid: Bool = false
    @State private var showCTA: Bool = false
    @State private var openingVisible: Bool = true

    enum Phase {
        case opening
        case sequence
        case finale
    }

    var body: some View {
        ZStack {
            // Background
            BrandGradientBackground()

            // Opening title
            if phase == .opening && openingVisible {
                GlowingText(text: vm.showcaseOpeningTitle, size: 56, color: .white, glowColor: .purple)
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
                    .padding()
            }

            // Single gift reveal (unique names only), image centered, name under image
            if phase == .sequence, let item = sequenceItem(at: currentIndex) {
                GeometryReader { geo in
                    VStack(spacing: 14) {
                        ZStack {
                            // halo
                            RadialGradient(colors: [Color.purple.opacity(0.25), .clear],
                                           center: .center, startRadius: 10, endRadius: 520)
                                .blur(radius: 28)
                                .opacity(showCard ? 1 : 0)
                                .animation(.easeInOut(duration: 0.6), value: showCard)

                            Image(assetNameFor(prize: item))
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: geo.size.width * 0.7,
                                       maxHeight: geo.size.height * 0.45,
                                       alignment: .center)
                                .scaleEffect(showCard ? 1.0 : 0.88)
                                .opacity(showCard ? 1.0 : 0.0)
                                .shadow(color: Color.orange.opacity(0.55), radius: 24)
                                .shadow(color: Color.orange.opacity(0.35), radius: 48)
                                .animation(.spring(response: 0.7, dampingFraction: 0.85), value: showCard)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)

                        // Name directly under the image, centered
                        Text(item.name)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .opacity(showName ? 1.0 : 0.0)
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut(duration: 0.5), value: showName)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(
                        .asymmetric(
                            insertion: AnyTransition.opacity.combined(with: .scale(scale: 0.94)),
                            removal: AnyTransition.opacity.combined(with: .scale(scale: 1.06))
                        )
                    )
                    .padding()
                }
            }

            // Final grid + CTA
            if phase == .finale {
                VStack(spacing: 24) {
                    if showFinalGrid {
                        finalGrid
                            .transition(.opacity.combined(with: .scale))
                    }

                    if showCTA {
                        Button {
                            // Dramatic transition to draw screen
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showCTA = false
                                showFinalGrid = false
                            }
                            // small delay then proceed
                            Task { @MainActor in
                                try? await Task.sleep(nanoseconds: 350_000_000)
                                vm.proceedToDrawing()
                            }
                        } label: {
                            Text(vm.showcaseCTA)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .padding(.vertical, 14)
                                .padding(.horizontal, 28)
                                .background(
                                    LinearGradient(colors: [Color.blue, Color.purple],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                        .shadow(color: .purple.opacity(0.6), radius: 12)
                                )
                                .shadow(color: Color.purple.opacity(0.7), radius: 18, x: 0, y: 8)
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .task {
            await runSequence()
        }
    }

    // MARK: - Sequence Orchestration

    @MainActor
    private func runSequence() async {
        // Opening
        phase = .opening
        openingVisible = true
        try? await Task.sleep(nanoseconds: 3_800_000_000) // ~1.8s on screen
        withAnimation(.easeInOut(duration: 0.6)) {
            openingVisible = false
        }
        try? await Task.sleep(nanoseconds: 650_000_000)

        // Gift-by-gift (unique names)
        phase = .sequence
        let items = buildUniqueOrderedByName()
        for (i, _) in items.enumerated() {
            currentIndex = i
            showCard = false
            showName = false
            withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                showCard = true
            }
            try? await Task.sleep(nanoseconds: 350_000_000)
            withAnimation(.easeInOut(duration: 0.5)) {
                showName = true
            }
            // hold on screen ~2.2s total
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            // exit animation
            withAnimation(.easeInOut(duration: 0.5)) {
                showName = false
            }
            withAnimation(.easeInOut(duration: 0.55)) {
                showCard = false
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
        }

        // Finale
        phase = .finale
        withAnimation(.easeInOut(duration: 0.6)) {
            showFinalGrid = true
        }
        // brief grid glimpse
        try? await Task.sleep(nanoseconds: 900_000_000)
        withAnimation(.easeInOut(duration: 0.6)) {
            showCTA = true
        }
    }

    // MARK: - Views

    private var finalGrid: some View {
        let items = buildOrderedUnits()
        let columns = Array(repeating: GridItem(.flexible(minimum: 80), spacing: 12), count: 5)
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, prize in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    Image(assetNameFor(prize: prize))
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .shadow(color: Color.orange.opacity(0.4), radius: 8)
                }
                .frame(height: 80)
                .overlay(
                    LinearGradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.25), Color.white.opacity(0.0)],
                                   startPoint: .leading, endPoint: .trailing)
                        .blendMode(.screen)
                        .mask(
                            Rectangle()
                                .fill(.linearGradient(colors: [.clear, .white, .clear], startPoint: .leading, endPoint: .trailing))
                                .offset(x: shimmerOffset)
                        )
                        .animation(.linear(duration: 1.6).repeatForever(autoreverses: false), value: shimmerOffset)
                )
            }
        }
        .onAppear {
            shimmerOffset = -200
            withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
        }
    }

    @State private var shimmerOffset: CGFloat = -200

    // MARK: - Helpers

    // Expanded list (all units) for the final grid
    private func buildOrderedUnits() -> [Prize] {
        let order = [
            "قسيمة شراء 1500",
            "قسيمة شراء 2000",
            "Apple iPhone 17 Pro",
            "Samsung Galaxy S25 Ultra",
            "Apple MacBook Air"
        ]
        var result: [Prize] = []
        for name in order {
            let units = vm.expandedPrizes.filter { $0.name == name }
            result.append(contentsOf: units)
        }
        return result
    }

    // Unique-by-name list for the sequence
    private func buildUniqueOrderedByName() -> [Prize] {
        let order = [
            "قسيمة شراء 1500",
            "قسيمة شراء 2000",
            "Apple iPhone 17 Pro",
            "Samsung Galaxy S25 Ultra",
            "Apple MacBook Air"
        ]
        var seen = Set<String>()
        var result: [Prize] = []
        for name in order {
            if !seen.contains(name),
               let first = vm.expandedPrizes.first(where: { $0.name == name }) {
                result.append(first)
                seen.insert(name)
            }
        }
        return result
    }

    private func sequenceItem(at index: Int) -> Prize? {
        let items = buildUniqueOrderedByName()
        guard items.indices.contains(index) else { return nil }
        return items[index]
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

#Preview {
    let vm = DrawViewModel()
    vm.resetAll()
    return GiftsShowcaseScreen(vm: vm)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}
