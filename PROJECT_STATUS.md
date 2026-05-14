# PROJECT_STATUS

## Completed in this MVP
- Implemented SwiftUI app entry point and dashboard layout.
- Implemented todo/quest model with:
  - title
  - memo (optional text)
  - difficulty
  - XP reward
  - completion state
- Implemented CRUD behaviors:
  - Add quest
  - Edit quest
  - Delete quest
  - Complete/uncomplete quest
- Implemented gamification logic:
  - XP gain on completion
  - Level calculation from total XP
  - XP progress bar values
  - Total completed quests
  - Daily streak tracking
- Implemented achievements system with starter badges:
  - First quest
  - 10 quests completed
  - 3-day streak
  - Reach level 5
- Implemented local persistence with `UserDefaults` and `Codable` for tasks + player profile.
- Added beginner-friendly folder structure with separated models, views, view model, services.

## Current limitations
- No committed `.xcodeproj` file yet (source-only scaffold).
- Linux/non-macOS environment cannot compile SwiftUI/iOS targets.
- Test scaffold added (`TodoGameUITests/ProgressionLogicTests.swift`) but requires Xcode project wiring to run.
- Deleting completed tasks currently uses row context menu (not swipe-to-delete list gesture).
- Streak currently increases based on completion date comparisons; timezone edge cases should be tested on device.

## Recommended next tasks
1. Create and commit a full Xcode iOS project wrapper (`.xcodeproj`) around existing source files.
2. Add unit tests for:
   - XP-to-level conversion
   - streak transitions
   - achievement unlock conditions
3. Add UI tests for create/edit/complete flows.
4. Improve UX polish:
   - custom theme tokens
   - animation feedback on quest completion
   - celebratory badge unlock banner
5. Optionally migrate persistence from `UserDefaults` to SwiftData/CoreData if data complexity grows.
