# Todo Quest

Todo Quest is a native SwiftUI iOS app that turns daily tasks into a small game loop.

## Features

- Add, complete, and delete quests.
- Earn XP and coins when quests are completed.
- Level up automatically as XP grows.
- Track daily progress with a game-style HUD.
- Persist tasks and player progress locally with `UserDefaults`.

## Open in Xcode

Open `TodoGameUI.xcodeproj`, choose an iPhone simulator, then run the app.

## Product Direction

Todo Quest should feel less like a normal checklist app and more like an RPG quest log for real life. The core experience should borrow from game quest systems: main quests, side quests, multi-step objectives, rewards, progress bars, unlocks, and clear quest states.

The goal is to make everyday tasks feel structured, motivating, and visually satisfying without making the app too complicated to use.

## Game Quest UX Roadmap

### 1. Quest Types

Add a quest type system so every task has a clearer role.

- Main Quest: important long-term goals or major life objectives.
- Side Quest: smaller tasks that support a main quest.
- Challenge: harder one-off tasks with higher rewards.
- Repeatable Quest: daily, weekly, or monthly quests that reset.

Example:

- Main Quest: Reach TOEIC 900.
- Side Quest: Memorize 50 words.
- Side Quest: Complete one listening practice set.
- Challenge: Take a full mock test.

### 2. Multi-Step Objectives

A quest should be able to contain several objectives. The quest is completed only when all required objectives are done.

Example:

- Quest: Complete workout routine.
- Objective 1: Stretch.
- Objective 2: Strength training.
- Objective 3: Cardio.

Recommended UI:

- Show objective progress as `2/3`.
- Add a progress bar inside each quest card.
- Let users check objectives individually.
- Change the quest state to "Ready to Claim" when every objective is complete.

### 3. Quest Chains

Support connected quests where completing one quest unlocks the next step.

Example:

- Learn SwiftUI basics.
- Build a simple screen.
- Apply the screen to Todo Quest.

This works especially well for study, self-development, fitness, and long-term goals.

### 4. Quest States

Use clear quest states so the user immediately understands what can be done.

- In Progress: the quest has unfinished objectives.
- Ready to Claim: all objectives are complete, but the reward has not been claimed yet.
- Completed: reward has been claimed.
- Locked: requirements have not been met.
- Expired: the quest passed its deadline.

Recommended UI:

- In Progress: normal quest card.
- Ready to Claim: highlighted border and visible claim button.
- Completed: dimmed card with completed stamp.
- Locked: darker card with unlock requirement.
- Expired: muted card with expired label.

### 5. Rewards and Progression

Make rewards visible before completion.

- XP reward.
- Coin reward.
- Streak bonus.
- Badge or title reward.
- Unlock reward, such as a new quest chain or difficulty.

Recommended UI:

- Show rewards on the right side or bottom of each quest card.
- Use compact labels like `+30 XP`, `+10 Coins`.
- Give harder quests stronger visual treatment.

### 6. Difficulty and Rarity

Keep the current difficulty system, but consider adding rarity-like presentation.

- Easy / Normal / Hard / Boss for effort.
- Common / Rare / Epic / Legendary for visual importance or reward value.

Recommended UI:

- Use border color, icon, and badge style to show difficulty.
- Avoid relying only on text.
- Boss or Legendary quests should feel visually special, but not noisy.

### 7. Quest Categories and Boards

Quest categories should feel like different boards or guilds.

Suggested categories:

- Daily Quest.
- Weekly Quest.
- Monthly Quest.
- Long-Term Quest.
- Study.
- Friends.
- Self-Development.
- Exercise.
- Work.
- Life.
- Custom.

Recommended UI:

- Use filters or tabs for period-based views.
- Use category chips or board sections for life areas.
- Let users edit category names and colors later.

### 8. Reset Timers

Daily, weekly, and monthly quests should clearly show when they reset.

Recommended UI:

- Daily: "Resets tonight".
- Weekly: "Resets in 3 days".
- Monthly: "Resets May 31".
- Long-term: no reset timer.

This helps the app feel closer to a real game quest board.

### 9. Main Quest and Side Quest Relationship

Allow side quests to belong to a main quest.

Recommended behavior:

- A main quest can contain multiple side quests.
- Completing side quests can increase main quest progress.
- A main quest can be completed manually or automatically when required side quests are complete.

Recommended UI:

- Main quest cards should be larger and more prominent.
- Side quests can appear indented under the main quest.
- Use a connecting line or grouped section to show the relationship.

## Suggested Implementation Order

1. Add `QuestType`: main, side, challenge, repeatable.
2. Add `QuestObjective` model with title and completion state.
3. Update quest completion logic so multi-step quests can become "Ready to Claim".
4. Add progress display: objective count and progress bar.
5. Add quest states: in progress, ready to claim, completed, locked, expired.
6. Add optional parent quest relationship for side quests.
7. Add quest chain or unlock requirements.
8. Improve UI with quest board grouping, reward previews, and stronger state styling.
9. Add category customization for user-defined areas like study, friends, growth, and exercise.

## AI Development Notes

When continuing development, preserve the app's current Minecraft-inspired quest board style, but prioritize usability over decoration.

Important principles:

- The first screen should remain the usable quest board, not a landing page.
- Quest cards should communicate status, progress, reward, and category at a glance.
- New systems should be added gradually so the app does not become hard to use.
- Prefer SwiftUI-native state and simple local persistence before adding server or cloud features.
- Keep previews updated so UI changes can be checked quickly in Xcode Canvas.
