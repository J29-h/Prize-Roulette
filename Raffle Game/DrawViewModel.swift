//
//  DrawViewModel.swift
//  Raffle Game
//
//  Created by Jana Abdulaziz Malibari on 28/06/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class DrawViewModel: ObservableObject {

    // MARK: - Published UI State
    @Published var drawState: DrawState = .start

    // The full list of prizes to draw (expanded into 10 individual prize units)
    @Published private(set) var expandedPrizes: [Prize] = []

    // Index of the currently active prize unit (0...9)
    @Published private(set) var currentIndex: Int = 0

    // Numbers pool (1...300) that remain available for drawing
    @Published private(set) var availableNumbers: Set<Int> = []

    // Temporary rolling number shown during drawing animation
    @Published var rollingNumber: Int = 0

    // The final selected number for the current (unconfirmed) prize
    @Published var selectedNumber: Int? = nil

    // Keep track of a reserved (unconfirmed) number removed from the pool,
    // so we can return it if the user redraws.
    private var reservedUnconfirmedNumber: Int? = nil

    // Confirmed winners
    @Published private(set) var winners: [Winner] = []

    // MARK: - Timing / Animation Controls
    @Published var isRolling: Bool = false

    // MARK: - Constants
    let totalNumbersRange = 1...300

    // Arabic UI strings (change fonts externally; these are content)
    let titleText = "السحب على جوائز الحفل السنوي"
    let subtitleText = "لحظات من الإثارة… وبدايات للفائزين"
    let startCTA = "ابدأ السحب"
    let startDrawText = "ابدأ السحب"
    let winningNumberLabel = "الرقم الفائز"
    let confirmWinnerText = "تأكيد الفائز"
    let redrawText = "إعادة السحب لهذه الجائزة"
    let nextPrizeText = "التالي"
    let congratulationsTitle = "تهانينا للفائزين"
    let restartText = "إعادة تشغيل النظام"
    let exportText = "نسخ النتائج كنص"
    let countdownNumbers = ["3", "2", "1"]
    let showcaseOpeningTitle = "جوائز سنة 2026"
    let showcaseCTA = "ابدأ السحوبات"

    // MARK: - Init
    init() {
        buildPrizeList()
    }

    // Build the full expanded prize list (10 total)
    func buildPrizeList() {
        // Base prize definitions (with quantities)
        let base: [Prize] = [
            Prize(name: "Apple MacBook Air", quantity: 1, symbolName: "laptopcomputer"),
            Prize(name: "Samsung Galaxy S25 Ultra", quantity: 1, symbolName: "iphone.gen3"),
            Prize(name: "Apple iPhone 17 Pro", quantity: 3, symbolName: "iphone.gen3"),
            Prize(name: "قسيمة شراء 2000", quantity: 3, symbolName: "giftcard"),
            Prize(name: "قسيمة شراء 1500", quantity: 2, symbolName: "giftcard")
        ]

        // Expand into unique prize units so we draw exactly 10 times
        var expanded: [Prize] = []
        for p in base {
            for _ in 0..<p.quantity {
                expanded.append(Prize(name: p.name, quantity: 1, symbolName: p.symbolName))
            }
        }
        self.expandedPrizes = expanded
    }

    // Reset all data to initial state
    func resetAll() {
        availableNumbers = Set(totalNumbersRange)
        winners = []
        selectedNumber = nil
        reservedUnconfirmedNumber = nil
        currentIndex = 0
        isRolling = false
        rollingNumber = 0
        drawState = .start
    }

    // Start flow from Start -> Showcase
    func beginRaffle() {
        guard !expandedPrizes.isEmpty else { return }
        drawState = .showcase
    }

    // After showcase (or countdown), go to drawing
    func proceedToDrawing() {
        selectedNumber = nil
        reservedUnconfirmedNumber = nil
        isRolling = false
        drawState = .drawing
    }

    // Start the rolling animation and eventually pick a number
    func startRolling() {
        guard !isRolling else { return }
        guard !availableNumbers.isEmpty else { return }

        isRolling = true

        Task {
            let start = Date()
            let duration: TimeInterval = 2.5
            while Date().timeIntervalSince(start) < duration {
                if let temp = availableNumbers.randomElement() {
                    rollingNumber = temp
                }
                try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
            }

            // End of rolling: choose a final number from availableNumbers
            if let final = availableNumbers.randomElement() {
                // If we had previously reserved an unconfirmed number (from a prior roll),
                // return it to the pool before reserving the new one.
                if let prev = reservedUnconfirmedNumber {
                    availableNumbers.insert(prev)
                    reservedUnconfirmedNumber = nil
                }

                // Reserve the new final: remove from pool immediately to prevent duplicates
                availableNumbers.remove(final)
                reservedUnconfirmedNumber = final

                selectedNumber = final
                rollingNumber = final
            }

            isRolling = false
            drawState = .result
        }
    }

    // Redraw only for current prize (if not confirmed yet)
    func redrawForCurrentPrize() {
        guard drawState == .result else { return }

        // If we had a reserved unconfirmed number, return it to the pool
        if let prev = reservedUnconfirmedNumber {
            availableNumbers.insert(prev)
            reservedUnconfirmedNumber = nil
        }

        // Clear selection and go back to drawing state
        selectedNumber = nil
        isRolling = false
        drawState = .drawing
    }

    // Confirm the selected number for the current prize
    func confirmWinner() {
        guard drawState == .result, let number = selectedNumber else { return }

        // Number is already removed from availableNumbers at reservation time.
        // Clear the reservation marker.
        reservedUnconfirmedNumber = nil

        let samePrizeCount = winners.filter { $0.prizeName == expandedPrizes[currentIndex].name }.count
        let seqIndex = samePrizeCount + 1

        let win = Winner(prizeName: expandedPrizes[currentIndex].name,
                         number: number,
                         sequenceIndex: seqIndex)
        winners.append(win)

        if currentIndex + 1 < expandedPrizes.count {
            currentIndex += 1
            selectedNumber = nil
            drawState = .countdown
        } else {
            drawState = .summary
        }
    }

    // Export results as plain text (Arabic friendly)
    func resultsText() -> String {
        var lines: [String] = []
        lines.append(congratulationsTitle)
        lines.append("")

        let grouped = Dictionary(grouping: winners, by: { $0.prizeName })
        let orderedPrizeNames = expandedPrizes.map { $0.name }
        let uniqueOrderedPrizeNames = Array(NSOrderedSet(array: orderedPrizeNames)) as? [String] ?? orderedPrizeNames

        for pname in uniqueOrderedPrizeNames {
            if let group = grouped[pname] {
                let sorted = group.sorted { $0.sequenceIndex < $1.sequenceIndex }
                let numbers = sorted.map { "\($0.number)" }.joined(separator: "، ")
                lines.append("\(pname): \(numbers)")
            }
        }

        return lines.joined(separator: "\n")
    }

    func copyResultsToPasteboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = resultsText()
        #endif
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resultsText(), forType: .string)
        #endif
    }

    func restartSystem() {
        resetAll()
    }

    var currentPrize: Prize? {
        guard expandedPrizes.indices.contains(currentIndex) else { return nil }
        return expandedPrizes[currentIndex]
    }

    var largeNumberString: String {
        if let s = selectedNumber { return "\(s)" }
        return "\(rollingNumber)"
    }
}
