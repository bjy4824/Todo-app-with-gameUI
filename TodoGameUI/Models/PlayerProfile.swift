import Foundation

struct PlayerProfile: Codable {
    var name: String
    var level: Int
    var totalXP: Int
    var completedTasksCount: Int
    var dailyStreak: Int
    var lastCompletionDate: Date?
    var achievements: [Achievement]

    static let starter = PlayerProfile(
        name: "Adventurer",
        level: 1,
        totalXP: 0,
        completedTasksCount: 0,
        dailyStreak: 0,
        lastCompletionDate: nil,
        achievements: Achievement.defaultSet()
    )

    var xpNeededForNextLevel: Int {
        100 + (level - 1) * 40
    }

    var xpIntoCurrentLevel: Int {
        totalXP - xpThresholdForCurrentLevel
    }

    var xpThresholdForCurrentLevel: Int {
        var threshold = 0
        guard level > 1 else { return 0 }

        for stage in 1..<level {
            threshold += 100 + (stage - 1) * 40
        }
        return threshold
    }

    var progressToNextLevel: Double {
        guard xpNeededForNextLevel > 0 else { return 0 }
        return min(1, Double(xpIntoCurrentLevel) / Double(xpNeededForNextLevel))
    }
}
