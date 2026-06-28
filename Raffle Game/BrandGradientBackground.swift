//
//  BrandGradientBackground.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// Uses the "Background" image from Assets if available, otherwise falls back to the gradient.
// Keeps radial lighting and particles for the luxurious, cinematic feel.
struct BrandGradientBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Try to load Background asset
            #if canImport(UIKit)
            if let uiImage = UIImage(named: "Background") {
                Image(uiImage: uiImage)
                    .resizable()
                    // Fit to the screen: preserves aspect, no cropping
                    .scaledToFit()
                    // Stretch the view to the window bounds while keeping fit behavior
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    // Show gradient where the image doesn't cover
                    .background(fallbackGradient)
                    .ignoresSafeArea()
            } else {
                fallbackGradient
            }
            #else
            // Cross‑platform: try SwiftUI Image init first
            if let _ = NSImageOrNil(named: "Background") {
                Image("Background")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(fallbackGradient)
                    .ignoresSafeArea()
            } else {
                fallbackGradient
            }
            #endif

            // Soft radial lighting overlay
            RadialGradient(colors: [
                Color.purple.opacity(0.15),
                Color.clear
            ], center: .topTrailing, startRadius: 100, endRadius: 800)
            .blendMode(.screen)
            .ignoresSafeArea()

            // Floating particles
            ParticleField()
                .allowsHitTesting(false)
                .opacity(0.6)
        }
    }

    // Extracted fallback gradient for reuse
    private var fallbackGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 14/255, green: 16/255, blue: 30/255),
                Color(red: 26/255, green: 20/255, blue: 53/255),
                Color(red: 40/255, green: 22/255, blue: 75/255)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#if !canImport(UIKit)
// Helper to check if an asset exists on non-UIKit platforms
import AppKit
private func NSImageOrNil(named name: String) -> NSImage? {
    NSImage(named: NSImage.Name(name))
}
#endif

// Simple particle effect using circles (unchanged)
struct ParticleField: View {
    @State private var t: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { ctx, size in
                let count = 80
                for i in 0..<count {
                    let progress = CGFloat(i) / CGFloat(count)
                    var x = sin(progress * 10 + t) * 120 + size.width * 0.5
                    var y = cos(progress * 8 + t * 1.2) * 80 + size.height * 0.5

                    // Slight drift
                    x += sin(t + progress * 4) * 40
                    y += cos(t + progress * 3.2) * 30

                    let rect = CGRect(x: x, y: y, width: 2, height: 2)
                    ctx.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(0.25)))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                t = 1000
            }
        }
    }
}
