//
//  SummaryOverlay.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI

struct SummaryOverlay: View {
    @ObservedObject var vm: DrawViewModel
    var dismiss: () -> Void

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            // Card
            VStack(spacing: 20) {
                Text(vm.congratulationsTitle)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(orderedPrizeNames(), id: \.self) { prizeName in
                            if let winnersForPrize = winners(for: prizeName), !winnersForPrize.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(prizeName)
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.95))

                                    Text(winnersForPrize.map { "\($0.number)" }.joined(separator: "، "))
                                        .font(.system(size: 18, weight: .regular, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .frame(maxWidth: 800, alignment: .center)
                    .padding(.horizontal)
                }
                .frame(maxHeight: 420)

                HStack(spacing: 14) {
                    Button {
                        vm.copyResultsToPasteboard()
                    } label: {
                        Text(vm.exportText)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(.white.opacity(0.12))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        vm.restartSystem()
                        dismiss()
                    } label: {
                        Text(vm.restartText)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color.orange.gradient)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.orange.opacity(0.6), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)

                    Button {
                        dismiss()
                    } label: {
                        Text("إغلاق")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(.white.opacity(0.08))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 6)
            }
            .padding(24)
            .frame(maxWidth: 1000)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 20)
            )
            .padding()
        }
    }

    // Helpers

    private func orderedPrizeNames() -> [String] {
        let names = vm.expandedPrizes.map { $0.name }
        // Keep order but unique
        var seen = Set<String>()
        var ordered: [String] = []
        for n in names where !seen.contains(n) {
            seen.insert(n)
            ordered.append(n)
        }
        return ordered
    }

    private func winners(for prizeName: String) -> [Winner]? {
        let filtered = vm.winners
            .filter { $0.prizeName == prizeName }
            .sorted { $0.sequenceIndex < $1.sequenceIndex }
        return filtered.isEmpty ? nil : filtered
    }
}

#Preview {
    let vm = DrawViewModel()
    vm.resetAll()
    // Seed some fake winners for preview
    vm.beginRaffle()
    vm.proceedToDrawing()
    return SummaryOverlay(vm: vm, dismiss: {})
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}
