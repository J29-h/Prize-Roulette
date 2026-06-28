//
//  AdaptiveWideLayout.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI

// A two-column adaptive layout that shows main content + a right-side panel
struct AdaptiveWideLayout<Main: View, Side: View>: View {
    let main: () -> Main
    let side: () -> Side

    init(@ViewBuilder _ main: @escaping () -> Main,
         @ViewBuilder side: @escaping () -> Side) {
        self.main = main
        self.side = side
    }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 24) {
                main()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                side()
                    .frame(width: max(320, min(420, geo.size.width * 0.28)))
            }
        }
    }
}

