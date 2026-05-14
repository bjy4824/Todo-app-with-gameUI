import Foundation

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool
    var unlockedAt: Date?

    static func defaultSet() -> [Achievement] {
        [
            Achievement(id: "first_quest", title: "First Quest", description: "Complete your first quest.", icon: "sparkles", isUnlocked: false),
            Achievement(id: "task_10", title: "Quest Adept", description: "Complete 10 quests.", icon: "star.circle", isUnlocked: false),
            Achievement(id: "streak_3", title: "On Fire", description: "Reach a 3-day streak.", icon: "flame", isUnlocked: false),
            Achievement(id: "level_5", title: "Rising Hero", description: "Reach level 5.", icon: "shield.lefthalf.filled", isUnlocked: false)
        ]
    }
}
