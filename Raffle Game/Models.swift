//
//  Models.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import Foundation

// Represents the overall UI flow
enum DrawState: Equatable {
    case start
    case showcase     // NEW: gifts cinematic screen
    case countdown
    case drawing
    case result
    case summary
}

// Represents a prize item (name, quantity, image symbol)
struct Prize: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let quantity: Int
    let symbolName: String // SF Symbol or placeholder identifier
}

// Represents a confirmed winner for a specific prize instance
struct Winner: Identifiable, Hashable {
    let id = UUID()
    let prizeName: String
    let number: Int
    let sequenceIndex: Int // which one in the prize’s quantity (e.g., iPhone 17 Pro #2 of 3)
}

