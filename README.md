# Prize Roulette

A macOS prize-draw roulette game built in **SwiftUI** for live events. It runs on a big screen, draws winning ticket numbers one prize at a time, and builds suspense with a countdown and rolling numbers. The interface is in Arabic.

## How it works

1. **Showcase:** a cinematic screen presents all the prizes.
2. **Countdown:** each prize gets its own countdown.
3. **Roll:** numbers spin across the ticket pool (1–300) and stop on a random winner.
4. **Reveal:** the winning number is shown on screen. The host can **confirm** it or **redraw** it, for example if the winner isn't present.
5. **Summary:** after the last prize, all winners are listed by prize and can be copied in one click to share.

## Highlights

- **Fair draw:** a confirmed number is removed from the pool, so no ticket can win twice. A redrawn number goes back in.
- **Multi-quantity prizes:** a prize with several units, such as 3 phones, is drawn one unit at a time, and winners are numbered in order.
- **State-driven flow:** a single `DrawViewModel` moves the app through `start → showcase → countdown → drawing → result → summary`.
- **Custom animations:** rolling numbers, a spring-animated countdown, glowing text, and an animated gradient background, all built in SwiftUI.

## Tech

Swift · SwiftUI · MVVM · macOS 26+

## Run it

1. Open `Raffle Game.xcodeproj` in Xcode 26 or later.
2. Select **My Mac** and press **Run** (⌘R).

The prize list and ticket range are set in `DrawViewModel.swift` (`buildPrizeList()` and `totalNumbersRange`).
