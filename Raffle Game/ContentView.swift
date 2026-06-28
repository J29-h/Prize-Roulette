//
//  ContentView.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var vm = DrawViewModel()

    var body: some View {
        ZStack {
            BrandGradientBackground()

            Group {
                switch vm.drawState {
                case .start:
                    StartScreen(vm: vm)
                case .showcase:
                    GiftsShowcaseScreen(vm: vm)
                case .countdown:
                    DrawScreen(vm: vm)
                case .drawing, .result, .summary:
                    DrawScreen(vm: vm)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .preferredColorScheme(.dark)
        }
        .onAppear {
            vm.resetAll()
        }
        // Global default font for the app UI
        .environment(\.font, .custom("Elm-Regular", size: 22))
    }
}

#Preview {
    ContentView()
}
