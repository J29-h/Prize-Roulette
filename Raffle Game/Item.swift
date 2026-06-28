//
//  Item.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
