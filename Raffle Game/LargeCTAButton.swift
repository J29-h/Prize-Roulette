//
//  LargeCTAButton.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI

struct LargeCTAButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .padding(.vertical, 18)
                .padding(.horizontal, 36)
                .background(
                    LinearGradient(colors: [Color.purple, Color.blue],
                                   startPoint: .leading, endPoint: .trailing)
                        .clipShape(Capsule())
                        .shadow(color: Color.purple.opacity(0.6), radius: 16, x: 0, y: 8)
                )
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}

