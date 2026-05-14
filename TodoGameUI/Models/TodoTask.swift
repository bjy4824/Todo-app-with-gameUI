import Foundation

struct TodoTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var memo: String
    var difficulty: TaskDifficulty
    var xpReward: Int
    var isCompleted: Bool
    var rewardClaimed: Bool
    var createdAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        memo: String = "",
        difficulty: TaskDifficulty,
        xpReward: Int,
        isCompleted: Bool = false,
        rewardClaimed: Bool = false,
        createdAt: Date = .now,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.memo = memo
        self.difficulty = difficulty
        self.xpReward = xpReward
        self.isCompleted = isCompleted
        self.rewardClaimed = rewardClaimed
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}

enum TaskDifficulty: String, CaseIterable, Codable, Identifiable {
    case easy
    case normal
    case hard
    case epic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        case .epic: return "Epic"
        }
    }

    var defaultXP: Int {
        switch self {
        case .easy: return 10
        case .normal: return 20
        case .hard: return 35
        case .epic: return 50
        }
    }
}
