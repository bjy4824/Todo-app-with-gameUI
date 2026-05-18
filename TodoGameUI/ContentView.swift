import SwiftUI
import UserNotifications

enum QuestDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case boss = "Boss"

    var id: String { rawValue }

    var xp: Int {
        switch self {
        case .easy: 15
        case .normal: 30
        case .hard: 55
        case .boss: 90
        }
    }

    var coins: Int {
        switch self {
        case .easy: 6
        case .normal: 12
        case .hard: 24
        case .boss: 45
        }
    }

    var icon: String {
        switch self {
        case .easy: "leaf.fill"
        case .normal: "hammer.fill"
        case .hard: "flame.fill"
        case .boss: "crown.fill"
        }
    }

    var tint: Color {
        switch self {
        case .easy: BlockTheme.emerald
        case .normal: BlockTheme.gold
        case .hard: BlockTheme.redstone
        case .boss: BlockTheme.diamond
        }
    }
}

enum QuestScope: String, CaseIterable, Identifiable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case longTerm = "Long-term"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .daily: "sun.max.fill"
        case .weekly: "calendar.badge.clock"
        case .monthly: "calendar"
        case .longTerm: "mountain.2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .daily: BlockTheme.gold
        case .weekly: BlockTheme.emerald
        case .monthly: BlockTheme.diamond
        case .longTerm: BlockTheme.redstone
        }
    }
}

enum QuestCategory: String, CaseIterable, Identifiable, Codable {
    case study = "Study"
    case friends = "Friends"
    case selfGrowth = "Growth"
    case exercise = "Exercise"
    case work = "Work"
    case life = "Life"
    case custom = "Custom"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .study: "book.closed.fill"
        case .friends: "person.2.fill"
        case .selfGrowth: "sparkles"
        case .exercise: "figure.strengthtraining.traditional"
        case .work: "briefcase.fill"
        case .life: "house.fill"
        case .custom: "slider.horizontal.3"
        }
    }

    var tint: Color {
        switch self {
        case .study: BlockTheme.diamond
        case .friends: BlockTheme.gold
        case .selfGrowth: BlockTheme.emerald
        case .exercise: BlockTheme.redstone
        case .work: Color(red: 0.78, green: 0.58, blue: 0.38)
        case .life: BlockTheme.grass
        case .custom: BlockTheme.dimText
        }
    }
}

enum QuestType: String, CaseIterable, Identifiable, Codable {
    case main = "Main"
    case side = "Side"
    case challenge = "Challenge"
    case repeatable = "Repeatable"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .main: "flag.fill"
        case .side: "signpost.right.fill"
        case .challenge: "bolt.fill"
        case .repeatable: "repeat"
        }
    }

    var tint: Color {
        switch self {
        case .main: BlockTheme.gold
        case .side: BlockTheme.emerald
        case .challenge: BlockTheme.redstone
        case .repeatable: BlockTheme.diamond
        }
    }

    var sortPriority: Int {
        switch self {
        case .main: 0
        case .challenge: 1
        case .side: 2
        case .repeatable: 3
        }
    }
}

enum QuestStatus: String {
    case inProgress = "In Progress"
    case readyToClaim = "Ready"
    case completed = "Completed"

    var icon: String {
        switch self {
        case .inProgress: "hourglass"
        case .readyToClaim: "gift.fill"
        case .completed: "checkmark.seal.fill"
        }
    }

    var tint: Color {
        switch self {
        case .inProgress: BlockTheme.dimText
        case .readyToClaim: BlockTheme.gold
        case .completed: BlockTheme.emerald
        }
    }
}

struct QuestObjective: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isComplete: Bool

    init(id: UUID = UUID(), title: String, isComplete: Bool = false) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
    }
}

struct Quest: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var type: QuestType
    var difficulty: QuestDifficulty
    var scope: QuestScope
    var category: QuestCategory
    var objectives: [QuestObjective]
    var isComplete: Bool
    var createdAt: Date
    var completedAt: Date?

    var rewardXP: Int { difficulty.xp }
    var rewardCoins: Int { difficulty.coins }
    var completedObjectiveCount: Int { objectives.filter(\.isComplete).count }
    var objectiveProgress: Double {
        guard !objectives.isEmpty else { return isComplete ? 1 : 0 }
        return Double(completedObjectiveCount) / Double(objectives.count)
    }
    var isReadyToClaim: Bool {
        !isComplete && !objectives.isEmpty && objectives.allSatisfy(\.isComplete)
    }
    var status: QuestStatus {
        if isComplete { return .completed }
        if isReadyToClaim { return .readyToClaim }
        return .inProgress
    }

    init(
        id: UUID = UUID(),
        title: String,
        type: QuestType = .side,
        difficulty: QuestDifficulty = .normal,
        scope: QuestScope = .daily,
        category: QuestCategory = .selfGrowth,
        objectives: [QuestObjective] = [],
        isComplete: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.difficulty = difficulty
        self.scope = scope
        self.category = category
        self.objectives = objectives
        self.isComplete = isComplete
        self.createdAt = createdAt
        self.completedAt = completedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case type
        case difficulty
        case scope
        case category
        case objectives
        case rewardXP
        case rewardCoins
        case isComplete
        case createdAt
        case completedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        type = try container.decodeIfPresent(QuestType.self, forKey: .type) ?? .side
        isComplete = try container.decodeIfPresent(Bool.self, forKey: .isComplete) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        scope = try container.decodeIfPresent(QuestScope.self, forKey: .scope) ?? .daily
        category = try container.decodeIfPresent(QuestCategory.self, forKey: .category) ?? .selfGrowth
        objectives = try container.decodeIfPresent([QuestObjective].self, forKey: .objectives) ?? []

        if let decodedDifficulty = try container.decodeIfPresent(QuestDifficulty.self, forKey: .difficulty) {
            difficulty = decodedDifficulty
        } else {
            let oldXP = try container.decodeIfPresent(Int.self, forKey: .rewardXP) ?? QuestDifficulty.normal.xp
            switch oldXP {
            case ..<25: difficulty = .easy
            case 25..<50: difficulty = .normal
            case 50..<80: difficulty = .hard
            default: difficulty = .boss
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(type, forKey: .type)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(scope, forKey: .scope)
        try container.encode(category, forKey: .category)
        try container.encode(objectives, forKey: .objectives)
        try container.encode(isComplete, forKey: .isComplete)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
    }
}

struct AchievementRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var difficulty: QuestDifficulty
    var earnedAt: Date
    var xp: Int
    var coins: Int

    init(id: UUID = UUID(), title: String, difficulty: QuestDifficulty, earnedAt: Date = Date(), xp: Int, coins: Int) {
        self.id = id
        self.title = title
        self.difficulty = difficulty
        self.earnedAt = earnedAt
        self.xp = xp
        self.coins = coins
    }
}

struct DailyRecord: Identifiable, Codable, Equatable {
    var id: String { dayKey }
    var dayKey: String
    var completed: Int
    var xp: Int
    var coins: Int
}

struct StoreItem: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var subtitle: String
    var price: Int
    var systemName: String
}

struct PlayerState: Codable, Equatable {
    var level: Int
    var xp: Int
    var coins: Int
    var streak: Int
    var lastCompletionDay: String?
    var ownedItemIDs: [String]

    static let fresh = PlayerState(level: 1, xp: 0, coins: 0, streak: 0, lastCompletionDay: nil, ownedItemIDs: [])

    var xpForCurrentLevel: Int {
        level * 100
    }

    var progress: Double {
        guard xpForCurrentLevel > 0 else { return 0 }
        return min(Double(xp) / Double(xpForCurrentLevel), 1)
    }

    enum CodingKeys: String, CodingKey {
        case level
        case xp
        case coins
        case streak
        case lastCompletionDay
        case ownedItemIDs
    }

    init(level: Int, xp: Int, coins: Int, streak: Int, lastCompletionDay: String?, ownedItemIDs: [String]) {
        self.level = level
        self.xp = xp
        self.coins = coins
        self.streak = streak
        self.lastCompletionDay = lastCompletionDay
        self.ownedItemIDs = ownedItemIDs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 1
        xp = try container.decodeIfPresent(Int.self, forKey: .xp) ?? 0
        coins = try container.decodeIfPresent(Int.self, forKey: .coins) ?? 0
        streak = try container.decodeIfPresent(Int.self, forKey: .streak) ?? 0
        lastCompletionDay = try container.decodeIfPresent(String.self, forKey: .lastCompletionDay)
        ownedItemIDs = try container.decodeIfPresent([String].self, forKey: .ownedItemIDs) ?? []
    }
}

enum QuestTab: String, CaseIterable, Identifiable {
    case quests = "Board"
    case log = "Achievements"
    case shop = "Shop"

    var id: String { rawValue }
}

enum BlockTheme {
    static let bedrock = Color(red: 0.06, green: 0.06, blue: 0.06)
    static let stone = Color(red: 0.29, green: 0.29, blue: 0.27)
    static let deepStone = Color(red: 0.13, green: 0.13, blue: 0.12)
    static let grass = Color(red: 0.23, green: 0.47, blue: 0.18)
    static let dirt = Color(red: 0.36, green: 0.22, blue: 0.12)
    static let gold = Color(red: 0.96, green: 0.78, blue: 0.22)
    static let emerald = Color(red: 0.22, green: 0.78, blue: 0.34)
    static let diamond = Color(red: 0.38, green: 0.86, blue: 0.94)
    static let redstone = Color(red: 0.87, green: 0.21, blue: 0.18)
    static let text = Color(red: 0.94, green: 0.92, blue: 0.82)
    static let dimText = Color(red: 0.66, green: 0.64, blue: 0.56)
}

@MainActor
final class QuestStore: ObservableObject {
    @Published var quests: [Quest] {
        didSet { save() }
    }

    @Published var achievements: [AchievementRecord] {
        didSet { save() }
    }

    @Published var dailyRecords: [DailyRecord] {
        didSet { save() }
    }

    @Published var player: PlayerState {
        didSet { save() }
    }

    @Published var notificationsEnabled: Bool {
        didSet { save() }
    }

    let shopItems = [
        StoreItem(id: "emerald-title", name: "Emerald Title", subtitle: "Show off a greener grind.", price: 75, systemName: "sparkles"),
        StoreItem(id: "diamond-badge", name: "Diamond Badge", subtitle: "A shiny badge for hard days.", price: 140, systemName: "diamond.fill"),
        StoreItem(id: "boss-banner", name: "Boss Banner", subtitle: "For players who clear the big tasks.", price: 220, systemName: "flag.fill")
    ]

    private let questsKey = "todo-quest.quests"
    private let playerKey = "todo-quest.player"
    private let achievementsKey = "todo-quest.achievements"
    private let dailyRecordsKey = "todo-quest.daily-records"
    private let notificationsKey = "todo-quest.notifications-enabled"

    init() {
        let decoder = JSONDecoder()
        if let questData = UserDefaults.standard.data(forKey: questsKey),
           let decodedQuests = try? decoder.decode([Quest].self, from: questData) {
            quests = decodedQuests
        } else {
            quests = [
                Quest(
                    title: "Build today's focus base",
                    type: .main,
                    difficulty: .normal,
                    scope: .daily,
                    category: .selfGrowth,
                    objectives: [
                        QuestObjective(title: "Choose one priority"),
                        QuestObjective(title: "Clear 25 minutes of focus")
                    ]
                ),
                Quest(
                    title: "Craft one hard study task",
                    type: .challenge,
                    difficulty: .hard,
                    scope: .weekly,
                    category: .study,
                    objectives: [
                        QuestObjective(title: "Prepare material"),
                        QuestObjective(title: "Finish the hard part"),
                        QuestObjective(title: "Write a short review")
                    ]
                ),
                Quest(title: "Place tomorrow's first block", type: .side, difficulty: .easy, scope: .daily, category: .life)
            ]
        }

        if let playerData = UserDefaults.standard.data(forKey: playerKey),
           let decodedPlayer = try? decoder.decode(PlayerState.self, from: playerData) {
            player = decodedPlayer
        } else {
            player = .fresh
        }

        if let achievementData = UserDefaults.standard.data(forKey: achievementsKey),
           let decodedAchievements = try? decoder.decode([AchievementRecord].self, from: achievementData) {
            achievements = decodedAchievements
        } else {
            achievements = []
        }

        if let recordsData = UserDefaults.standard.data(forKey: dailyRecordsKey),
           let decodedRecords = try? decoder.decode([DailyRecord].self, from: recordsData) {
            dailyRecords = decodedRecords
        } else {
            dailyRecords = []
        }

        notificationsEnabled = UserDefaults.standard.bool(forKey: notificationsKey)
    }

    var activeQuests: [Quest] {
        quests.filter { !$0.isComplete }
    }

    var completedQuests: [Quest] {
        quests.filter(\.isComplete)
    }

    var completedCount: Int {
        completedQuests.count
    }

    var completionRatio: Double {
        guard !quests.isEmpty else { return 0 }
        return Double(completedCount) / Double(quests.count)
    }

    var todayRecord: DailyRecord {
        dailyRecords.first { $0.dayKey == Self.dayKey(for: Date()) } ?? DailyRecord(dayKey: Self.dayKey(for: Date()), completed: 0, xp: 0, coins: 0)
    }

    func questCount(scope: QuestScope) -> Int {
        quests.filter { $0.scope == scope && !$0.isComplete }.count
    }

    func questCount(category: QuestCategory) -> Int {
        quests.filter { $0.category == category && !$0.isComplete }.count
    }

    func filteredQuests(scope: QuestScope?, category: QuestCategory?, isComplete: Bool) -> [Quest] {
        quests.filter { quest in
            quest.isComplete == isComplete
                && (scope == nil || quest.scope == scope)
                && (category == nil || quest.category == category)
        }
        .sorted { first, second in
            if first.isReadyToClaim != second.isReadyToClaim {
                return first.isReadyToClaim
            }
            if first.type.sortPriority != second.type.sortPriority {
                return first.type.sortPriority < second.type.sortPriority
            }
            return first.createdAt > second.createdAt
        }
    }

    func addQuest(title: String, type: QuestType, difficulty: QuestDifficulty, scope: QuestScope, category: QuestCategory, objectives: [QuestObjective]) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        quests.insert(Quest(title: trimmedTitle, type: type, difficulty: difficulty, scope: scope, category: category, objectives: objectives), at: 0)
    }

    func updateQuest(_ quest: Quest, title: String, type: QuestType, difficulty: QuestDifficulty, scope: QuestScope, category: QuestCategory, objectives: [QuestObjective]) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, let index = quests.firstIndex(of: quest) else { return }
        quests[index].title = trimmedTitle
        quests[index].type = type
        quests[index].difficulty = difficulty
        quests[index].scope = scope
        quests[index].category = category
        quests[index].objectives = objectives
    }

    func toggleQuest(_ quest: Quest) -> Bool {
        guard let index = quests.firstIndex(of: quest) else { return false }
        guard quests[index].objectives.isEmpty || quests[index].isReadyToClaim || quests[index].isComplete else { return false }
        quests[index].isComplete.toggle()

        if quests[index].isComplete {
            let completedQuest = quests[index]
            quests[index].completedAt = Date()
            award(for: completedQuest)
            achievements.insert(
                AchievementRecord(
                    title: completedQuest.title,
                    difficulty: completedQuest.difficulty,
                    xp: completedQuest.rewardXP,
                    coins: completedQuest.rewardCoins
                ),
                at: 0
            )
            updateDailyRecord(xp: completedQuest.rewardXP, coins: completedQuest.rewardCoins)
            updateStreak()
            return true
        } else {
            player.xp = max(0, player.xp - quests[index].rewardXP)
            player.coins = max(0, player.coins - quests[index].rewardCoins)
            quests[index].completedAt = nil
            return false
        }
    }

    func toggleObjective(_ objective: QuestObjective, in quest: Quest) {
        guard
            let questIndex = quests.firstIndex(of: quest),
            let objectiveIndex = quests[questIndex].objectives.firstIndex(of: objective),
            !quests[questIndex].isComplete
        else { return }
        quests[questIndex].objectives[objectiveIndex].isComplete.toggle()
    }

    func deleteQuest(_ quest: Quest) {
        quests.removeAll { $0.id == quest.id }
    }

    func resetDay() {
        quests = quests.map {
            var quest = $0
            quest.isComplete = false
            quest.completedAt = nil
            return quest
        }
    }

    func buy(_ item: StoreItem) {
        guard !player.ownedItemIDs.contains(item.id), player.coins >= item.price else { return }
        player.coins -= item.price
        player.ownedItemIDs.append(item.id)
    }

    func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            Task { @MainActor in
                self.notificationsEnabled = granted
                if granted {
                    self.scheduleDailyReminder()
                }
            }
        }
    }

    func scheduleDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-quest-reminder"])

        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Quest board waiting"
        content.body = "Clear at least one quest before the day resets."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-quest-reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func award(for quest: Quest) {
        player.xp += quest.rewardXP
        player.coins += quest.rewardCoins

        while player.xp >= player.xpForCurrentLevel {
            player.xp -= player.xpForCurrentLevel
            player.level += 1
        }
    }

    private func updateDailyRecord(xp: Int, coins: Int) {
        let key = Self.dayKey(for: Date())
        if let index = dailyRecords.firstIndex(where: { $0.dayKey == key }) {
            dailyRecords[index].completed += 1
            dailyRecords[index].xp += xp
            dailyRecords[index].coins += coins
        } else {
            dailyRecords.insert(DailyRecord(dayKey: key, completed: 1, xp: xp, coins: coins), at: 0)
        }
    }

    private func updateStreak() {
        let today = Self.dayKey(for: Date())
        guard player.lastCompletionDay != today else { return }

        if let last = player.lastCompletionDay, Self.isYesterday(last, before: today) {
            player.streak += 1
        } else {
            player.streak = 1
        }
        player.lastCompletionDay = today
    }

    private func save() {
        let encoder = JSONEncoder()
        if let questData = try? encoder.encode(quests) {
            UserDefaults.standard.set(questData, forKey: questsKey)
        }
        if let playerData = try? encoder.encode(player) {
            UserDefaults.standard.set(playerData, forKey: playerKey)
        }
        if let achievementData = try? encoder.encode(achievements) {
            UserDefaults.standard.set(achievementData, forKey: achievementsKey)
        }
        if let recordsData = try? encoder.encode(dailyRecords) {
            UserDefaults.standard.set(recordsData, forKey: dailyRecordsKey)
        }
        UserDefaults.standard.set(notificationsEnabled, forKey: notificationsKey)
    }

    static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func isYesterday(_ previousKey: String, before currentKey: String) -> Bool {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        guard
            let previous = formatter.date(from: previousKey),
            let current = formatter.date(from: currentKey),
            let expected = Calendar.current.date(byAdding: .day, value: -1, to: current)
        else { return false }
        return Calendar.current.isDate(previous, inSameDayAs: expected)
    }
}

struct ContentView: View {
    @StateObject private var store = QuestStore()
    @State private var selectedTab: QuestTab = .quests
    @State private var newQuestTitle = ""
    @State private var newQuestType: QuestType = .side
    @State private var newDifficulty: QuestDifficulty = .normal
    @State private var newScope: QuestScope = .daily
    @State private var newCategory: QuestCategory = .selfGrowth
    @State private var newObjectives: [QuestObjective] = []
    @State private var selectedScope: QuestScope?
    @State private var selectedCategory: QuestCategory?
    @State private var editingQuest: Quest?
    @State private var achievementTitle: String?
    @FocusState private var isAddingQuest: Bool

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                BlockWorldBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        AchievementHeader(store: store)
                        TabBar(selectedTab: $selectedTab)

                        switch selectedTab {
                        case .quests:
                            QuestPanel(
                                store: store,
                                title: $newQuestTitle,
                                questType: $newQuestType,
                                difficulty: $newDifficulty,
                                scope: $newScope,
                                category: $newCategory,
                                objectives: $newObjectives,
                                selectedScope: $selectedScope,
                                selectedCategory: $selectedCategory,
                                isFocused: _isAddingQuest,
                                onAdd: addQuest,
                                onEdit: { editingQuest = $0 },
                                onToggle: completeQuest,
                                onObjectiveToggle: { objective, quest in
                                    withAnimation(.snappy) {
                                        store.toggleObjective(objective, in: quest)
                                    }
                                }
                            )
                        case .log:
                            AchievementLogPanel(store: store)
                        case .shop:
                            ShopPanel(store: store)
                        }
                    }
                    .padding(16)
                    .padding(.top, 6)
                }

                if let achievementTitle {
                    AchievementToast(title: achievementTitle)
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationTitle("Todo Quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.requestNotifications()
                    } label: {
                        Image(systemName: store.notificationsEnabled ? "bell.badge.fill" : "bell.fill")
                    }
                    .tint(store.notificationsEnabled ? BlockTheme.emerald : BlockTheme.gold)
                    .accessibilityLabel("Enable daily reminder")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.snappy) {
                            store.resetDay()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .tint(BlockTheme.gold)
                    .accessibilityLabel("Reset daily quests")
                }
            }
            .sheet(item: $editingQuest) { quest in
                EditQuestSheet(quest: quest) { title, type, difficulty, scope, category, objectives in
                    store.updateQuest(quest, title: title, type: type, difficulty: difficulty, scope: scope, category: category, objectives: objectives)
                    editingQuest = nil
                }
            }
        }
    }

    private func addQuest() {
        store.addQuest(
            title: newQuestTitle,
            type: newQuestType,
            difficulty: newDifficulty,
            scope: newScope,
            category: newCategory,
            objectives: newObjectives
        )
        newQuestTitle = ""
        newObjectives = []
        isAddingQuest = false
    }

    private func completeQuest(_ quest: Quest) {
        withAnimation(.snappy) {
            if store.toggleQuest(quest) {
                showAchievement(quest.title)
            }
        }
    }

    private func showAchievement(_ title: String) {
        achievementTitle = title
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            withAnimation(.easeInOut(duration: 0.22)) {
                if achievementTitle == title {
                    achievementTitle = nil
                }
            }
        }
    }
}

struct BlockWorldBackground: View {
    private let columns = Array(repeating: GridItem(.fixed(34), spacing: 0), count: 12)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.09, green: 0.11, blue: 0.13),
                    Color(red: 0.08, green: 0.15, blue: 0.12),
                    Color(red: 0.17, green: 0.10, blue: 0.07)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<216, id: \.self) { index in
                    let row = index / 12
                    BlockTile(row: row, index: index)
                }
            }
            .opacity(0.44)
            .ignoresSafeArea()
        }
    }
}

struct BlockTile: View {
    let row: Int
    let index: Int

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 34, height: 34)
            .overlay(alignment: .topLeading) {
                Rectangle()
                    .fill(.white.opacity(0.07))
                    .frame(height: 3)
            }
            .overlay(alignment: .bottomTrailing) {
                Rectangle()
                    .fill(.black.opacity(0.24))
                    .frame(width: 3)
            }
    }

    private var color: Color {
        if row < 3 { return (index.isMultiple(of: 3) ? BlockTheme.grass : Color(red: 0.18, green: 0.33, blue: 0.16)) }
        if row < 6 { return (index.isMultiple(of: 4) ? BlockTheme.dirt : Color(red: 0.26, green: 0.16, blue: 0.10)) }
        return (index.isMultiple(of: 5) ? BlockTheme.stone : BlockTheme.deepStone)
    }
}

struct AchievementHeader: View {
    @ObservedObject var store: QuestStore

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ItemSlot(systemName: "crown.fill", tint: BlockTheme.gold, size: 56)

                VStack(alignment: .leading, spacing: 5) {
                    Text("ACHIEVEMENT LOG")
                        .font(.system(.caption, design: .monospaced).weight(.black))
                        .foregroundStyle(BlockTheme.gold)
                    Text("Level \(store.player.level) Crafter")
                        .font(.system(.title2, design: .monospaced).weight(.black))
                        .foregroundStyle(BlockTheme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Spacer()

                CurrencyBlock(value: store.player.coins)
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("XP BAR")
                    Spacer()
                    Text("\(store.player.xp)/\(store.player.xpForCurrentLevel)")
                }
                .font(.system(.caption, design: .monospaced).weight(.black))
                .foregroundStyle(BlockTheme.dimText)

                PixelProgress(value: store.player.progress)
            }

            HStack(spacing: 10) {
                ProgressTile(title: "DONE", value: "\(store.completedCount)/\(store.quests.count)")
                ProgressTile(title: "STREAK", value: "\(store.player.streak)")
                ProgressTile(title: "TODAY", value: "\(store.todayRecord.completed)")
            }
        }
        .padding(14)
        .blockPanel()
    }
}

struct TabBar: View {
    @Binding var selectedTab: QuestTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(QuestTab.allCases) { tab in
                Button {
                    withAnimation(.snappy) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue.uppercased())
                        .font(.system(.caption, design: .monospaced).weight(.black))
                        .foregroundStyle(selectedTab == tab ? .black : BlockTheme.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(selectedTab == tab ? BlockTheme.gold : Color.black.opacity(0.62))
                        .overlay {
                            Rectangle()
                                .stroke(selectedTab == tab ? .black.opacity(0.65) : BlockTheme.stone, lineWidth: 3)
                        }
                }
            }
        }
        .padding(8)
        .blockPanel()
    }
}

struct QuestPanel: View {
    @ObservedObject var store: QuestStore
    @Binding var title: String
    @Binding var questType: QuestType
    @Binding var difficulty: QuestDifficulty
    @Binding var scope: QuestScope
    @Binding var category: QuestCategory
    @Binding var objectives: [QuestObjective]
    @Binding var selectedScope: QuestScope?
    @Binding var selectedCategory: QuestCategory?
    @FocusState var isFocused: Bool
    let onAdd: () -> Void
    let onEdit: (Quest) -> Void
    let onToggle: (Quest) -> Void
    let onObjectiveToggle: (QuestObjective, Quest) -> Void

    private var activeFiltered: [Quest] {
        store.filteredQuests(scope: selectedScope, category: selectedCategory, isComplete: false)
    }

    private var completedFiltered: [Quest] {
        store.filteredQuests(scope: selectedScope, category: selectedCategory, isComplete: true)
    }

    var body: some View {
        VStack(spacing: 14) {
            AddQuestBar(
                title: $title,
                questType: $questType,
                difficulty: $difficulty,
                scope: $scope,
                category: $category,
                objectives: $objectives,
                isFocused: _isFocused,
                onAdd: onAdd
            )
            QuestFilters(store: store, selectedScope: $selectedScope, selectedCategory: $selectedCategory)

            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("ACTIVE QUESTS", value: "\(activeFiltered.count)")
                if activeFiltered.isEmpty {
                    EmptyQuestView(text: "No active quests match this filter. Change the scope or category to see more.")
                } else {
                    ForEach(activeFiltered) { quest in
                        QuestRow(
                            quest: quest,
                            onToggle: { onToggle(quest) },
                            onObjectiveToggle: { objective in onObjectiveToggle(objective, quest) },
                            onEdit: { onEdit(quest) },
                            onDelete: { store.deleteQuest(quest) }
                        )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("COMPLETED", value: "\(completedFiltered.count)")
                ForEach(completedFiltered.prefix(4)) { quest in
                    QuestRow(
                        quest: quest,
                        onToggle: { onToggle(quest) },
                        onObjectiveToggle: { objective in onObjectiveToggle(objective, quest) },
                        onEdit: { onEdit(quest) },
                        onDelete: { store.deleteQuest(quest) }
                    )
                }
            }
        }
    }
}

struct AddQuestBar: View {
    @Binding var title: String
    @Binding var questType: QuestType
    @Binding var difficulty: QuestDifficulty
    @Binding var scope: QuestScope
    @Binding var category: QuestCategory
    @Binding var objectives: [QuestObjective]
    @State private var showsOptions = false
    @FocusState var isFocused: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                TextField("New quest", text: $title)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit(onAdd)
                    .textInputAutocapitalization(.sentences)
                    .font(.system(.body, design: .monospaced).weight(.bold))
                    .foregroundStyle(BlockTheme.text)
                    .tint(BlockTheme.gold)
                    .padding(.horizontal, 12)
                    .frame(height: 52)
                    .background(BlockTheme.bedrock)
                    .overlay {
                        Rectangle()
                            .stroke(BlockTheme.stone, lineWidth: 3)
                    }

                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.black)
                        .frame(width: 52, height: 52)
                        .background(BlockTheme.gold)
                        .overlay {
                            Rectangle()
                                .stroke(.black.opacity(0.65), lineWidth: 3)
                        }
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.48 : 1)
                .accessibilityLabel("Add quest")
            }

            Button {
                withAnimation(.snappy) {
                    showsOptions.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    MiniTag(title: questType.rawValue, icon: questType.icon, tint: questType.tint)
                    MiniTag(title: difficulty.rawValue, icon: difficulty.icon, tint: difficulty.tint)
                    MiniTag(title: scope.rawValue, icon: scope.icon, tint: scope.tint)
                    MiniTag(title: category.rawValue, icon: category.icon, tint: category.tint)
                    Spacer()
                    Image(systemName: showsOptions ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.black))
                        .foregroundStyle(BlockTheme.dimText)
                }
            }
            .buttonStyle(.plain)

            if showsOptions {
                VStack(spacing: 10) {
                    QuestTypePicker(selection: $questType)
                    DifficultyPicker(selection: $difficulty)
                    ScopePicker(selection: $scope)
                    CategoryPicker(selection: $category)
                    ObjectiveEditor(objectives: $objectives)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .blockPanel()
    }
}

struct ObjectiveEditor: View {
    @Binding var objectives: [QuestObjective]
    @State private var draftTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OBJECTIVES")
                .font(.system(.caption2, design: .monospaced).weight(.black))
                .foregroundStyle(BlockTheme.dimText)

            if objectives.isEmpty {
                Text("No steps yet. Add steps for multi-condition quests.")
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .foregroundStyle(BlockTheme.dimText)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.32))
                    .overlay {
                        Rectangle()
                            .stroke(BlockTheme.stone, lineWidth: 2)
                    }
            } else {
                VStack(spacing: 6) {
                    ForEach(objectives) { objective in
                        HStack(spacing: 8) {
                            Image(systemName: objective.isComplete ? "checkmark.square.fill" : "square")
                                .foregroundStyle(objective.isComplete ? BlockTheme.emerald : BlockTheme.dimText)
                                .frame(width: 18)

                            Text(objective.title)
                                .font(.system(.caption, design: .monospaced).weight(.bold))
                                .foregroundStyle(BlockTheme.text)
                                .lineLimit(2)

                            Spacer(minLength: 0)

                            Button {
                                objectives.removeAll { $0.id == objective.id }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption2.weight(.black))
                                    .foregroundStyle(BlockTheme.dimText)
                                    .frame(width: 28, height: 28)
                            }
                            .accessibilityLabel("Remove objective")
                        }
                        .padding(.horizontal, 8)
                        .frame(minHeight: 34)
                        .background(Color.black.opacity(0.32))
                        .overlay {
                            Rectangle()
                                .stroke(BlockTheme.stone, lineWidth: 2)
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                TextField("Add objective", text: $draftTitle)
                    .submitLabel(.done)
                    .onSubmit(addObjective)
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .foregroundStyle(BlockTheme.text)
                    .tint(BlockTheme.gold)
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .background(BlockTheme.bedrock)
                    .overlay {
                        Rectangle()
                            .stroke(BlockTheme.stone, lineWidth: 3)
                    }

                Button(action: addObjective) {
                    Image(systemName: "plus")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.black)
                        .frame(width: 42, height: 40)
                        .background(BlockTheme.gold)
                        .overlay {
                            Rectangle()
                                .stroke(.black.opacity(0.65), lineWidth: 3)
                        }
                }
                .disabled(draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.48 : 1)
                .accessibilityLabel("Add objective")
            }
        }
    }

    private func addObjective() {
        let trimmed = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        objectives.append(QuestObjective(title: trimmed))
        draftTitle = ""
    }
}

struct QuestTypePicker: View {
    @Binding var selection: QuestType

    var body: some View {
        HorizontalChipPicker(title: "QUEST TYPE") {
            ForEach(QuestType.allCases) { type in
                ChipButton(
                    title: type.rawValue,
                    icon: type.icon,
                    tint: type.tint,
                    isSelected: selection == type
                ) {
                    selection = type
                }
            }
        }
    }
}

struct DifficultyPicker: View {
    @Binding var selection: QuestDifficulty

    var body: some View {
        HStack(spacing: 7) {
            ForEach(QuestDifficulty.allCases) { difficulty in
                Button {
                    selection = difficulty
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: difficulty.icon)
                        Text(difficulty.rawValue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                    }
                    .font(.system(.caption2, design: .monospaced).weight(.black))
                    .foregroundStyle(selection == difficulty ? .black : BlockTheme.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(selection == difficulty ? difficulty.tint : Color.black.opacity(0.58))
                    .overlay {
                        Rectangle()
                            .stroke(selection == difficulty ? .black.opacity(0.62) : BlockTheme.stone, lineWidth: 3)
                    }
                }
            }
        }
    }
}

struct ScopePicker: View {
    @Binding var selection: QuestScope

    var body: some View {
        HorizontalChipPicker(title: "PERIOD") {
            ForEach(QuestScope.allCases) { scope in
                ChipButton(
                    title: scope.rawValue,
                    icon: scope.icon,
                    tint: scope.tint,
                    isSelected: selection == scope
                ) {
                    selection = scope
                }
            }
        }
    }
}

struct CategoryPicker: View {
    @Binding var selection: QuestCategory

    var body: some View {
        HorizontalChipPicker(title: "CATEGORY") {
            ForEach(QuestCategory.allCases) { category in
                ChipButton(
                    title: category.rawValue,
                    icon: category.icon,
                    tint: category.tint,
                    isSelected: selection == category
                ) {
                    selection = category
                }
            }
        }
    }
}

struct QuestFilters: View {
    @ObservedObject var store: QuestStore
    @Binding var selectedScope: QuestScope?
    @Binding var selectedCategory: QuestCategory?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("FILTER")
                    .font(.system(.caption2, design: .monospaced).weight(.black))
                    .foregroundStyle(BlockTheme.dimText)
                Spacer()
                Button {
                    selectedScope = nil
                    selectedCategory = nil
                } label: {
                    Text("CLEAR")
                        .font(.system(.caption2, design: .monospaced).weight(.black))
                        .foregroundStyle(BlockTheme.gold)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                ChipButton(title: "All", icon: "square.grid.2x2.fill", tint: BlockTheme.gold, isSelected: selectedScope == nil) {
                    selectedCategory = nil
                    selectedScope = nil
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(QuestScope.allCases) { scope in
                            ChipButton(title: "\(scope.rawValue) \(store.questCount(scope: scope))", icon: scope.icon, tint: scope.tint, isSelected: selectedScope == scope) {
                                selectedScope = scope
                            }
                        }
                    }
                }
            }

            Menu {
                Button("All Categories") {
                    selectedCategory = nil
                }
                ForEach(QuestCategory.allCases) { category in
                    Button("\(category.rawValue) (\(store.questCount(category: category)))") {
                        selectedCategory = category
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: selectedCategory?.icon ?? "tray.full.fill")
                    Text(selectedCategory?.rawValue ?? "All Categories")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .font(.system(.caption, design: .monospaced).weight(.black))
                .foregroundStyle(BlockTheme.text)
                .padding(.horizontal, 10)
                .frame(height: 40)
                .background(Color.black.opacity(0.58))
                .overlay {
                    Rectangle()
                        .stroke(BlockTheme.stone, lineWidth: 3)
                }
            }
        }
        .padding(12)
        .blockPanel()
    }
}

struct HorizontalChipPicker<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(.caption2, design: .monospaced).weight(.black))
                .foregroundStyle(BlockTheme.dimText)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    content()
                }
            }
        }
    }
}

struct ChipButton: View {
    let title: String
    let icon: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .lineLimit(1)
            }
            .font(.system(.caption2, design: .monospaced).weight(.black))
            .foregroundStyle(isSelected ? .black : BlockTheme.text)
            .padding(.horizontal, 10)
            .frame(height: 36)
            .background(isSelected ? tint : Color.black.opacity(0.58))
            .overlay {
                Rectangle()
                    .stroke(isSelected ? .black.opacity(0.62) : BlockTheme.stone, lineWidth: 3)
            }
        }
        .buttonStyle(.plain)
    }
}

struct QuestRow: View {
    let quest: Quest
    let onToggle: () -> Void
    let onObjectiveToggle: (QuestObjective) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    ItemSlot(
                        systemName: quest.status.icon,
                        tint: quest.status.tint,
                        size: quest.type == .main ? 60 : 54
                    )
                }
                .buttonStyle(.plain)
                .disabled(!canToggleFromIcon)
                .opacity(canToggleFromIcon ? 1 : 0.72)
                .accessibilityLabel(quest.isReadyToClaim ? "Claim quest reward" : "Toggle quest")

                Button(action: onEdit) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            MiniTag(title: quest.type.rawValue, icon: quest.type.icon, tint: quest.type.tint)
                            MiniTag(title: quest.status.rawValue, icon: quest.status.icon, tint: quest.status.tint)
                        }

                        Text(quest.title)
                            .font(.system(quest.type == .main ? .title3 : .headline, design: .monospaced).weight(.black))
                            .foregroundStyle(BlockTheme.text)
                            .strikethrough(quest.isComplete, color: BlockTheme.gold)
                            .lineLimit(2)

                        HStack(spacing: 8) {
                            Text("+\(quest.rewardXP) XP")
                            Text("+\(quest.rewardCoins) coins")
                            if !quest.objectives.isEmpty {
                                Text("\(quest.completedObjectiveCount)/\(quest.objectives.count)")
                            }
                        }
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundStyle(quest.isReadyToClaim ? BlockTheme.gold : BlockTheme.emerald)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                VStack(spacing: 4) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.caption.weight(.black))
                            .foregroundStyle(BlockTheme.gold)
                            .frame(width: 34, height: 26)
                    }
                    .accessibilityLabel("Edit quest")

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption.weight(.black))
                            .foregroundStyle(BlockTheme.dimText)
                            .frame(width: 34, height: 26)
                    }
                    .accessibilityLabel("Delete quest")
                }
            }

            if !quest.objectives.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    PixelProgress(value: quest.objectiveProgress)
                        .frame(height: 14)

                    ForEach(quest.objectives) { objective in
                        ObjectiveRow(
                            objective: objective,
                            isQuestComplete: quest.isComplete,
                            onToggle: { onObjectiveToggle(objective) }
                        )
                    }
                }
            }

            HStack(spacing: 6) {
                MiniTag(title: quest.difficulty.rawValue, icon: quest.difficulty.icon, tint: quest.difficulty.tint)
                MiniTag(title: quest.scope.rawValue, icon: quest.scope.icon, tint: quest.scope.tint)
                MiniTag(title: quest.category.rawValue, icon: quest.category.icon, tint: quest.category.tint)
                Spacer(minLength: 0)
                if quest.isReadyToClaim {
                    ClaimButton(action: onToggle)
                } else if !quest.objectives.isEmpty && !quest.isComplete {
                    Text("FINISH \(quest.objectives.count - quest.completedObjectiveCount)")
                        .font(.system(.caption2, design: .monospaced).weight(.black))
                        .foregroundStyle(BlockTheme.dimText)
                        .frame(height: 24)
                }
            }
        }
        .padding(10)
        .background(backgroundColor)
        .overlay {
            Rectangle()
                .stroke(borderColor, lineWidth: quest.type == .main ? 4 : 3)
        }
        .shadow(color: .black.opacity(0.36), radius: 0, x: 3, y: 3)
    }

    private var backgroundColor: Color {
        if quest.isComplete { return Color(red: 0.08, green: 0.19, blue: 0.11) }
        if quest.isReadyToClaim { return Color(red: 0.22, green: 0.17, blue: 0.05) }
        return quest.type == .main ? Color(red: 0.16, green: 0.13, blue: 0.07) : BlockTheme.deepStone
    }

    private var borderColor: Color {
        if quest.isComplete { return BlockTheme.emerald }
        if quest.isReadyToClaim { return BlockTheme.gold }
        return quest.type == .main ? quest.type.tint : BlockTheme.stone
    }

    private var canToggleFromIcon: Bool {
        quest.objectives.isEmpty || quest.isReadyToClaim || quest.isComplete
    }
}

struct ClaimButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "gift.fill")
                Text("CLAIM")
            }
            .font(.system(.caption2, design: .monospaced).weight(.black))
            .foregroundStyle(.black)
            .padding(.horizontal, 9)
            .frame(height: 30)
            .background(BlockTheme.gold)
            .overlay {
                Rectangle()
                    .stroke(.black.opacity(0.68), lineWidth: 3)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Claim quest reward")
    }
}

struct ObjectiveRow: View {
    let objective: QuestObjective
    let isQuestComplete: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: objective.isComplete ? "checkmark.square.fill" : "square")
                    .font(.caption.weight(.black))
                    .foregroundStyle(objective.isComplete ? BlockTheme.emerald : BlockTheme.dimText)
                    .frame(width: 18)
                Text(objective.title)
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .foregroundStyle(objective.isComplete ? BlockTheme.dimText : BlockTheme.text)
                    .strikethrough(objective.isComplete, color: BlockTheme.emerald)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .frame(minHeight: 30)
            .background(Color.black.opacity(0.32))
            .overlay {
                Rectangle()
                    .stroke(Color.black.opacity(0.52), lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
        .disabled(isQuestComplete)
    }
}

struct EditQuestSheet: View {
    let quest: Quest
    let onSave: (String, QuestType, QuestDifficulty, QuestScope, QuestCategory, [QuestObjective]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var type: QuestType
    @State private var difficulty: QuestDifficulty
    @State private var scope: QuestScope
    @State private var category: QuestCategory
    @State private var objectives: [QuestObjective]

    init(quest: Quest, onSave: @escaping (String, QuestType, QuestDifficulty, QuestScope, QuestCategory, [QuestObjective]) -> Void) {
        self.quest = quest
        self.onSave = onSave
        _title = State(initialValue: quest.title)
        _type = State(initialValue: quest.type)
        _difficulty = State(initialValue: quest.difficulty)
        _scope = State(initialValue: quest.scope)
        _category = State(initialValue: quest.category)
        _objectives = State(initialValue: quest.objectives)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BlockWorldBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        TextField("Quest title", text: $title)
                            .font(.system(.body, design: .monospaced).weight(.bold))
                            .foregroundStyle(BlockTheme.text)
                            .padding(12)
                            .background(BlockTheme.bedrock)
                            .overlay {
                                Rectangle()
                                    .stroke(BlockTheme.stone, lineWidth: 3)
                            }

                        DifficultyPicker(selection: $difficulty)
                        QuestTypePicker(selection: $type)
                        ScopePicker(selection: $scope)
                        CategoryPicker(selection: $category)
                        ObjectiveEditor(objectives: $objectives)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Edit Quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, type, difficulty, scope, category, objectives)
                    }
                }
            }
        }
    }
}

struct AchievementLogPanel: View {
    @ObservedObject var store: QuestStore

    var body: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("TODAY", value: "\(store.todayRecord.completed)")
                HStack(spacing: 10) {
                    ProgressTile(title: "XP", value: "\(store.todayRecord.xp)")
                    ProgressTile(title: "COINS", value: "\(store.todayRecord.coins)")
                    ProgressTile(title: "STREAK", value: "\(store.player.streak)")
                }
            }
            .padding(12)
            .blockPanel()

            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("UNLOCKED", value: "\(store.achievements.count)")
                if store.achievements.isEmpty {
                    EmptyQuestView(text: "Complete a quest to unlock your first achievement.")
                } else {
                    ForEach(store.achievements.prefix(18)) { achievement in
                        AchievementLogRow(achievement: achievement)
                    }
                }
            }
        }
    }
}

struct AchievementLogRow: View {
    let achievement: AchievementRecord

    var body: some View {
        HStack(spacing: 12) {
            ItemSlot(systemName: achievement.difficulty.icon, tint: achievement.difficulty.tint, size: 48)
            VStack(alignment: .leading, spacing: 5) {
                Text("Achievement Get!")
                    .font(.system(.caption2, design: .monospaced).weight(.black))
                    .foregroundStyle(BlockTheme.gold)
                Text(achievement.title)
                    .font(.system(.subheadline, design: .monospaced).weight(.black))
                    .foregroundStyle(BlockTheme.text)
                    .lineLimit(2)
                Text("\(achievement.xp) XP · \(achievement.coins) coins")
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .foregroundStyle(BlockTheme.dimText)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.black.opacity(0.62))
        .overlay {
            Rectangle()
                .stroke(BlockTheme.stone, lineWidth: 3)
        }
    }
}

struct ShopPanel: View {
    @ObservedObject var store: QuestStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle("REWARD SHOP", value: "\(store.player.coins) coins")

            ForEach(store.shopItems) { item in
                let owned = store.player.ownedItemIDs.contains(item.id)
                HStack(spacing: 12) {
                    ItemSlot(systemName: item.systemName, tint: owned ? BlockTheme.emerald : BlockTheme.gold, size: 50)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.name)
                            .font(.system(.headline, design: .monospaced).weight(.black))
                            .foregroundStyle(BlockTheme.text)
                        Text(item.subtitle)
                            .font(.system(.caption, design: .monospaced).weight(.bold))
                            .foregroundStyle(BlockTheme.dimText)
                    }
                    Spacer()
                    Button {
                        withAnimation(.snappy) {
                            store.buy(item)
                        }
                    } label: {
                        Text(owned ? "OWNED" : "\(item.price)")
                            .font(.system(.caption, design: .monospaced).weight(.black))
                            .foregroundStyle(owned ? .black : BlockTheme.text)
                            .frame(width: 68, height: 36)
                            .background(owned ? BlockTheme.emerald : Color.black.opacity(0.55))
                            .overlay {
                                Rectangle()
                                    .stroke(owned ? .black.opacity(0.65) : BlockTheme.stone, lineWidth: 3)
                            }
                    }
                    .disabled(owned || store.player.coins < item.price)
                    .opacity(!owned && store.player.coins < item.price ? 0.45 : 1)
                }
                .padding(10)
                .background(BlockTheme.deepStone)
                .overlay {
                    Rectangle()
                        .stroke(BlockTheme.stone, lineWidth: 3)
                }
            }

            ReminderCard(store: store)
        }
        .padding(12)
        .blockPanel()
    }
}

struct ReminderCard: View {
    @ObservedObject var store: QuestStore

    var body: some View {
        HStack(spacing: 12) {
            ItemSlot(systemName: "bell.fill", tint: store.notificationsEnabled ? BlockTheme.emerald : BlockTheme.gold, size: 48)
            VStack(alignment: .leading, spacing: 5) {
                Text("Daily reminder")
                    .font(.system(.headline, design: .monospaced).weight(.black))
                    .foregroundStyle(BlockTheme.text)
                Text(store.notificationsEnabled ? "8 PM reminder is armed." : "Tap to enable an 8 PM quest nudge.")
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .foregroundStyle(BlockTheme.dimText)
            }
            Spacer()
            Button {
                store.requestNotifications()
            } label: {
                Image(systemName: store.notificationsEnabled ? "checkmark" : "plus")
                    .foregroundStyle(.black)
                    .frame(width: 42, height: 36)
                    .background(store.notificationsEnabled ? BlockTheme.emerald : BlockTheme.gold)
                    .overlay {
                        Rectangle()
                            .stroke(.black.opacity(0.65), lineWidth: 3)
                    }
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.62))
        .overlay {
            Rectangle()
                .stroke(BlockTheme.stone, lineWidth: 3)
        }
    }
}

struct AchievementToast: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            ItemSlot(systemName: "diamond.fill", tint: BlockTheme.emerald, size: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text("Achievement Get!")
                    .font(.system(.caption, design: .monospaced).weight(.black))
                    .foregroundStyle(BlockTheme.gold)
                Text(title)
                    .font(.system(.subheadline, design: .monospaced).weight(.black))
                    .foregroundStyle(BlockTheme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: 340)
        .background(Color.black.opacity(0.88))
        .overlay {
            Rectangle()
                .stroke(BlockTheme.gold, lineWidth: 3)
        }
        .shadow(color: .black.opacity(0.42), radius: 0, x: 3, y: 3)
        .padding(.horizontal, 18)
    }
}

struct ItemSlot: View {
    let systemName: String
    let tint: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.72))
                .frame(width: size, height: size)
                .overlay(alignment: .topLeading) {
                    Rectangle()
                        .fill(.white.opacity(0.18))
                        .frame(width: size, height: 4)
                }
                .overlay(alignment: .bottomTrailing) {
                    Rectangle()
                        .fill(.black.opacity(0.48))
                        .frame(width: 4, height: size)
                }
                .overlay {
                    Rectangle()
                        .stroke(BlockTheme.stone, lineWidth: 3)
                }

            Image(systemName: systemName)
                .font(.system(size: size * 0.43, weight: .black))
                .foregroundStyle(tint)
                .shadow(color: .black.opacity(0.45), radius: 0, x: 1, y: 1)
        }
    }
}

struct PixelProgress: View {
    let value: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.black.opacity(0.75))

                Rectangle()
                    .fill(BlockTheme.emerald)
                    .frame(width: max(8, geometry.size.width * value))
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(.white.opacity(0.25))
                            .frame(height: 3)
                    }
            }
            .overlay {
                Rectangle()
                    .stroke(.black.opacity(0.85), lineWidth: 3)
            }
        }
        .frame(height: 18)
    }
}

struct ProgressTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(.caption2, design: .monospaced).weight(.black))
                .foregroundStyle(BlockTheme.dimText)
            Text(value)
                .font(.system(.title3, design: .monospaced).weight(.black))
                .foregroundStyle(BlockTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.black.opacity(0.52))
        .overlay {
            Rectangle()
                .stroke(BlockTheme.stone, lineWidth: 3)
        }
    }
}

struct CurrencyBlock: View {
    let value: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "circle.hexagongrid.fill")
            Text("\(value)")
                .monospacedDigit()
        }
        .font(.system(.headline, design: .monospaced).weight(.black))
        .foregroundStyle(.black)
        .padding(.horizontal, 10)
        .frame(height: 38)
        .background(BlockTheme.gold)
        .overlay {
            Rectangle()
                .stroke(.black.opacity(0.72), lineWidth: 3)
        }
    }
}

struct MiniTag: View {
    let title: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 9, weight: .black, design: .monospaced))
        .foregroundStyle(.black)
        .padding(.horizontal, 6)
        .frame(height: 20)
        .background(tint)
        .overlay {
            Rectangle()
                .stroke(.black.opacity(0.58), lineWidth: 2)
        }
    }
}

struct SectionTitle: View {
    let title: String
    let value: String

    init(_ title: String, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.system(.caption, design: .monospaced).weight(.black))
                .foregroundStyle(BlockTheme.gold)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced).weight(.black))
                .foregroundStyle(BlockTheme.dimText)
        }
    }
}

struct EmptyQuestView: View {
    let text: String

    var body: some View {
        VStack(spacing: 10) {
            ItemSlot(systemName: "flag.checkered", tint: BlockTheme.gold, size: 62)
            Text("Nothing unlocked yet")
                .font(.system(.headline, design: .monospaced).weight(.black))
                .foregroundStyle(BlockTheme.text)
            Text(text)
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundStyle(BlockTheme.dimText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .blockPanel()
    }
}

struct BlockPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.black.opacity(0.78))
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.white.opacity(0.10))
                    .frame(height: 4)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(.black.opacity(0.42))
                    .frame(height: 4)
            }
            .overlay {
                Rectangle()
                    .stroke(BlockTheme.stone, lineWidth: 4)
            }
            .shadow(color: .black.opacity(0.36), radius: 0, x: 3, y: 3)
    }
}

extension View {
    func blockPanel() -> some View {
        modifier(BlockPanelModifier())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDisplayName("Full Quest Board")

            PreviewQuestRows()
                .previewDisplayName("Quest Card States")
        }
    }
}

struct PreviewQuestRows: View {
    private let inProgressQuest = Quest(
        title: "Finish SwiftUI quest board polish",
        type: .main,
        difficulty: .hard,
        scope: .weekly,
        category: .study,
        objectives: [
            QuestObjective(title: "Fix claim button", isComplete: true),
            QuestObjective(title: "Improve objective editor"),
            QuestObjective(title: "Check preview states")
        ]
    )

    private let readyQuest = Quest(
        title: "Complete morning workout chain",
        type: .challenge,
        difficulty: .boss,
        scope: .daily,
        category: .exercise,
        objectives: [
            QuestObjective(title: "Stretch", isComplete: true),
            QuestObjective(title: "Strength training", isComplete: true),
            QuestObjective(title: "Cardio", isComplete: true)
        ]
    )

    private let completedQuest = Quest(
        title: "Send a message to a friend",
        type: .side,
        difficulty: .easy,
        scope: .daily,
        category: .friends,
        objectives: [],
        isComplete: true,
        completedAt: Date()
    )

    var body: some View {
        ZStack {
            BlockWorldBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    SectionTitle("PREVIEW STATES", value: "3")
                    QuestRow(
                        quest: inProgressQuest,
                        onToggle: {},
                        onObjectiveToggle: { _ in },
                        onEdit: {},
                        onDelete: {}
                    )
                    QuestRow(
                        quest: readyQuest,
                        onToggle: {},
                        onObjectiveToggle: { _ in },
                        onEdit: {},
                        onDelete: {}
                    )
                    QuestRow(
                        quest: completedQuest,
                        onToggle: {},
                        onObjectiveToggle: { _ in },
                        onEdit: {},
                        onDelete: {}
                    )
                }
                .padding(16)
            }
        }
    }
}
