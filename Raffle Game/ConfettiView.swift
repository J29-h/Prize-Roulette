//
//  ConfettiView.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI

// Simple confetti using Canvas
struct ConfettiView: View {
    @State private var time: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { ctx, size in
                let count: Int = 140
                let heightPlusMargin: CGFloat = size.height + 80.0
                let fallSpeed: CGFloat = 80.0
                let spacingY: CGFloat = 12.0
                let pieceWidth: CGFloat = 6.0
                let pieceHeight: CGFloat = 10.0
                let cornerRadius: CGFloat = 2.0

                for i in 0..<count {
                    let cgI: CGFloat = CGFloat(i)
                    let cgCount: CGFloat = CGFloat(count)

                    let progress: CGFloat = cgI / cgCount
                    let x: CGFloat = size.width * progress

                    let baseY: CGFloat = time * fallSpeed + cgI * spacingY
                    var y: CGFloat = baseY.truncatingRemainder(dividingBy: heightPlusMargin) - 80.0

                    if y < -80.0 {
                        y += heightPlusMargin
                    }

                    let rect = CGRect(x: x, y: y, width: pieceWidth, height: pieceHeight)

                    let hueBase: CGFloat = progress * 0.9
                    let hueWrapped: CGFloat = hueBase.truncatingRemainder(dividingBy: 1.0)
                    let color = Color(hue: Double(hueWrapped), saturation: 0.8, brightness: 0.95, opacity: 0.9)

                    let path = Path(roundedRect: rect, cornerRadius: cornerRadius)
                    ctx.fill(path, with: .color(color))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                time = 1000
            }
        }
        .allowsHitTesting(false)
    }
}
