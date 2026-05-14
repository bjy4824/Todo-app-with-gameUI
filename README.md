# Todo-app-with-gameUI

A SwiftUI-first MVP for a **gamified todo app** where tasks are treated like quests.

## What is included
- Quest/task CRUD (add, edit, delete, complete)
- Difficulty-based XP rewards
- Player profile with level, XP progress, streak, and completed-quest stats
- Basic achievements/badges
- Local persistence using `UserDefaults` + `Codable`
- Clean folder structure for `Models`, `Views`, `ViewModels`, and `Services`

## Project structure
- `TodoGameUI/App` – App entry point
- `TodoGameUI/Models` – data models
- `TodoGameUI/ViewModels` – app state and game logic
- `TodoGameUI/Services` – persistence utilities
- `TodoGameUI/Views` – screens and UI components

## Open and run in Xcode
1. Open Xcode.
2. Create a new **iOS App** project named `TodoGameUI` (SwiftUI lifecycle).
3. Replace generated source files with the files in this repository under `TodoGameUI/`.
4. Ensure deployment target is iOS 17+ (or iOS 16+ with minor UI adjustments).
5. Build and run on Simulator.

> Note: This repo currently provides complete source files and structure, but not a checked-in `.xcodeproj` yet.

## Suggested next steps in Xcode
- Add unit tests for level progression and streak logic.
- Add UI tests for task creation/completion flows.
- Add app icons and custom color assets for stronger game identity.


## Tests
- A starter unit test file is included under `TodoGameUITests/` to guide Xcode test setup.
