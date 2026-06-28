//
//  GlowingText.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI

struct GlowingText: View {
    var text: String
    var size: CGFloat
    var color: Color = .white
    var glowColor: Color = .purple

    // Global enlargement factor for all GlowingText uses
    private let boost: CGFloat = 1.25

    var body: some View {
        Text(text)
            // Inherit the caller's custom font (family). We only make it bolder.
            .fontWeight(.bold)
            // Apply a uniform size boost so everything appears larger
            .environment(\.sizeCategory, .large) // keeps dynamic type reasonable
            .font(.system(size: size * boost))   // only scales size; family is provided by caller via .font(.custom(...))
            .foregroundStyle(color)
            .shadow(color: glowColor.opacity(0.6), radius: 12, x: 0, y: 0)
            .shadow(color: glowColor.opacity(0.6), radius: 24, x: 0, y: 0)
    }
}
