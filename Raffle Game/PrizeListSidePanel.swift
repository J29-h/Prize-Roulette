//
//  PrizeListSidePanel.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI

struct PrizeListSidePanel: View {
    let prizes: [Prize]
    let winners: [Winner]
    let currentIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("الجوائز")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(prizes.enumerated()), id: \.offset) { idx, prize in
                        HStack(spacing: 12) {
                            Image(systemName: prize.symbolName)
                                .foregroundStyle(.white.opacity(0.9))
                                .imageScale(.large)
                                .frame(width: 36, height: 36)
                                .background(.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(prize.name)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                // Show winner number if already confirmed for this unit
                                if let winner = winnerForIndex(idx) {
                                    Text("الفائز: \(winner.number)")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundStyle(Color.orange)
                                } else {
                                    Text("لم يتم السحب بعد")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }

                            Spacer()

                            if let currentIndex, currentIndex == idx {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 10, height: 10)
                            }
                        }
                        .padding(10)
                        .background(.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func winnerForIndex(_ index: Int) -> Winner? {
        guard prizes.indices.contains(index) else { return nil }
        let name = prizes[index].name
        // Winners are stored by name+sequence; since we expanded to units, we map by order
        let allForName = winners.filter { $0.prizeName == name }.sorted { $0.sequenceIndex < $1.sequenceIndex }
        // Determine which sequence index this unit is. Count previous same-name units up to index
        let seq = prizes.prefix(index + 1).filter { $0.name == name }.count
        return allForName.first { $0.sequenceIndex == seq }
    }
}

