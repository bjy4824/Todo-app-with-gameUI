# Touch Score Product Plan

## Product Idea

Touch Score is an offline-first scoring app for sports, classes, events, and casual matches. The primary screen is an iPad-friendly scoreboard that can be controlled by touch. Later, an iPhone app can act as the bridge for Apple Watch control, while optional cloud sync can back up games and share live scores.

## Core Problem

People often need a quick scoreboard in gyms, classrooms, tournaments, or small events where Wi-Fi can be unreliable. A server-only app fails in those places. The app should work first on the device in front of the scorekeeper, then sync when a network is available.

## MVP

- Large two-team scoreboard optimized for iPad touch use.
- Tap the score area to add one point.
- Use visible plus and minus controls for correction.
- Rename teams before or during a match.
- Run a match timer with start, pause, and reset.
- Undo the most recent scoring action.
- Reset a match without losing the app state.
- Save the current match locally on the device.
- Keep a room code and remote-control URL for testing watch or phone control over the local network.

## Apple Watch Direction

Apple Watch cannot pair directly with iPad in the normal consumer setup. For a production Apple Watch feature, the best path is:

- iPad app: main offline scoreboard.
- iPhone app: companion app and sync bridge.
- watchOS app: simple remote with Home +, Home -, Away +, Away -.
- WatchConnectivity: iPhone and Apple Watch exchange score commands.
- Local persistence: iPad and iPhone store match state locally.
- Optional cloud sync: sync history and live score when internet is available.

## App Store Direction

A simple web wrapper is risky for App Store review. The iOS/iPadOS release should include native value:

- Offline match storage.
- iPad-optimized scoreboard.
- Apple Watch control.
- Match history.
- Local network or iCloud sync.
- Haptics and native controls.

## Later Features

- Match presets for basketball, volleyball, table tennis, badminton, soccer, and custom scoring.
- Periods, sets, fouls, timeouts, possession, and serve indicator.
- QR code for remote control pairing.
- Export match history as CSV or PDF.
- Live share link for spectators.
- Referee mode with locked controls.
- Multiple scoreboard layouts.
