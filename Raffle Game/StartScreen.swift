//
//  StartScreen.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI

struct StartScreen: View {
    @ObservedObject var vm: DrawViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            // elm logo from assets (replace "elmLogo" with your actual asset name if different)
            ZStack {
                Circle().fill(.white.opacity(0.06)).frame(width: 140, height: 140)
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100) // slightly larger for raster logo
                    .shadow(color: Color.blue.opacity(0.8), radius: 16) // adjust or remove if not desired
            }
            .padding(.bottom, 8)

            GlowingText(text: vm.titleText, size: 44, color: .white, glowColor: .purple)

            Text(vm.subtitleText)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))

            LargeCTAButton(title: vm.startCTA) {
                vm.beginRaffle()
            }
            .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
}
