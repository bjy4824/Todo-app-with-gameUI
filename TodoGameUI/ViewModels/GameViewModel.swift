import Foundation
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published var tasks: [TodoTask] = []
    @Published var profile: PlayerProfile = .starter

    private let storage = LocalStorageService()
    private let tasksKey = "todo_game_tasks"
    private let profileKey = "todo_game_profile"

    init() {
        loadState()
    }

    var activeTasks: [TodoTask] { tasks.filter { !$0.isCompleted } }
    var completedTasks: [TodoTask] { tasks.filter(\.isCompleted) }

    func addTask(title: String, memo: String, difficulty: TaskDifficulty, xpReward: Int?) {
        let value = max(1, xpReward ?? difficulty.defaultXP)
        let task = TodoTask(title: title, memo: memo, difficulty: difficulty, xpReward: value)
        tasks.insert(task, at: 0)
        saveState()
    }

    func updateTask(_ task: TodoTask, title: String, memo: String, difficulty: TaskDifficulty, xpReward: Int?) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].title = title
        tasks[idx].memo = memo
        tasks[idx].difficulty = difficulty
        tasks[idx].xpReward = max(1, xpReward ?? difficulty.defaultXP)
        saveState()
    }

    func deleteTask(_ task: TodoTask) {
        tasks.removeAll { $0.id == task.id }
        saveState()
    }

    func toggleTaskCompletion(_ task: TodoTask) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].isCompleted.toggle()

        if tasks[idx].isCompleted {
            tasks[idx].completedAt = .now
            if !tasks[idx].rewardClaimed {
                tasks[idx].rewardClaimed = true
                applyCompletionRewards(for: tasks[idx])
            }
        } else {
            tasks[idx].completedAt = nil
        }

        saveState()
    }

    private func applyCompletionRewards(for task: TodoTask) {
        profile.totalXP += task.xpReward
        profile.completedTasksCount += 1
        updateStreak(using: Date())
        updateLevelFromXP()
        unlockAchievementsIfNeeded()
    }

    private func updateStreak(using completionDate: Date) {
        let calendar = Calendar.current
        guard let lastDate = profile.lastCompletionDate else {
            profile.dailyStreak = 1
            profile.lastCompletionDate = completionDate
            return
        }

        if calendar.isDate(completionDate, inSameDayAs: lastDate) {
            profile.lastCompletionDate = completionDate
            return
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: completionDate),
           calendar.isDate(lastDate, inSameDayAs: yesterday) {
            profile.dailyStreak += 1
        } else {
            profile.dailyStreak = 1
        }

        profile.lastCompletionDate = completionDate
    }

    private func updateLevelFromXP() {
        var level = 1
        var remainingXP = profile.totalXP
        var requirement = 100

        while remainingXP >= requirement {
            remainingXP -= requirement
            level += 1
            requirement = 100 + (level - 1) * 40
        }

        profile.level = level
    }

    private func unlockAchievementsIfNeeded() {
        unlock("first_quest", when: profile.completedTasksCount >= 1)
        unlock("task_10", when: profile.completedTasksCount >= 10)
        unlock("streak_3", when: profile.dailyStreak >= 3)
        unlock("level_5", when: profile.level >= 5)
    }

    private func unlock(_ id: String, when condition: Bool) {
        guard condition,
              let idx = profile.achievements.firstIndex(where: { $0.id == id }),
              !profile.achievements[idx].isUnlocked else {
            return
        }
        profile.achievements[idx].isUnlocked = true
        profile.achievements[idx].unlockedAt = .now
    }

    private func loadState() {
        if let storedTasks = storage.load([TodoTask].self, forKey: tasksKey) {
            tasks = storedTasks
        }
        if let storedProfile = storage.load(PlayerProfile.self, forKey: profileKey) {
            profile = storedProfile
        }
    }

    private func saveState() {
        storage.save(tasks, forKey: tasksKey)
        storage.save(profile, forKey: profileKey)
    }
}
