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

struct Quest: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var difficulty: QuestDifficulty
    var isComplete: Bool
    var createdAt: Date
    var completedAt: Date?

    var rewardXP: Int { difficulty.xp }
    var rewardCoins: Int { difficulty.coins }

    init(
        id: UUID = UUID(),
        title: String,
        difficulty: QuestDifficulty = .normal,
        isComplete: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.difficulty = difficulty
        self.isComplete = isComplete
        self.createdAt = createdAt
        self.completedAt = completedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case difficulty
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
        isComplete = try container.decodeIfPresent(Bool.self, forKey: .isComplete) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)

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
        try container.encode(difficulty, forKey: .difficulty)
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
    case quests = "Quests"
    case log = "Log"
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
                Quest(title: "Gather morning focus", difficulty: .easy),
                Quest(title: "Craft one hard task", difficulty: .hard),
                Quest(title: "Place tomorrow's first block", difficulty: .normal)
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

    func addQuest(title: String, difficulty: QuestDifficulty) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        quests.insert(Quest(title: trimmedTitle, difficulty: difficulty), at: 0)
    }

    func updateQuest(_ quest: Quest, title: String, difficulty: QuestDifficulty) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, let index = quests.firstIndex(of: quest) else { return }
        quests[index].title = trimmedTitle
        quests[index].difficulty = difficulty
    }

    func toggleQuest(_ quest: Quest) -> Bool {
        guard let index = quests.firstIndex(of: quest) else { return false }
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
    @State private var newDifficulty: QuestDifficulty = .normal
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
                                difficulty: $newDifficulty,
                                isFocused: _isAddingQuest,
                                onAdd: addQuest,
                                onEdit: { editingQuest = $0 },
                                onToggle: completeQuest
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
                EditQuestSheet(quest: quest) { title, difficulty in
                    store.updateQuest(quest, title: title, difficulty: difficulty)
                    editingQuest = nil
                }
            }
        }
    }

    private func addQuest() {
        store.addQuest(title: newQuestTitle, difficulty: newDifficulty)
        newQuestTitle = ""
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
    @Binding var difficulty: QuestDifficulty
    @FocusState var isFocused: Bool
    let onAdd: () -> Void
    let onEdit: (Quest) -> Void
    let onToggle: (Quest) -> Void

    var body: some View {
        VStack(spacing: 14) {
            AddQuestBar(title: $title, difficulty: $difficulty, isFocused: _isFocused, onAdd: onAdd)

            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("ACTIVE QUESTS", value: "\(store.activeQuests.count)")
                if store.activeQuests.isEmpty {
                    EmptyQuestView(text: "No active quests. Add a new task to start mining progress.")
                } else {
                    ForEach(store.activeQuests) { quest in
                        QuestRow(quest: quest, onToggle: { onToggle(quest) }, onEdit: { onEdit(quest) }, onDelete: { store.deleteQuest(quest) })
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("COMPLETED", value: "\(store.completedQuests.count)")
                ForEach(store.completedQuests.prefix(4)) { quest in
                    QuestRow(quest: quest, onToggle: { onToggle(quest) }, onEdit: { onEdit(quest) }, onDelete: { store.deleteQuest(quest) })
                }
            }
        }
    }
}

struct AddQuestBar: View {
    @Binding var title: String
    @Binding var difficulty: QuestDifficulty
    @FocusState var isFocused: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                TextField("Type a new achievement", text: $title)
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

            DifficultyPicker(selection: $difficulty)
        }
        .padding(12)
        .blockPanel()
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

struct QuestRow: View {
    let quest: Quest
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ItemSlot(
                    systemName: quest.isComplete ? "checkmark.seal.fill" : quest.difficulty.icon,
                    tint: quest.isComplete ? BlockTheme.emerald : quest.difficulty.tint,
                    size: 54
                )
            }
            .buttonStyle(.plain)

            Button(action: onToggle) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(quest.isComplete ? "Achievement Get!" : "\(quest.difficulty.rawValue) Achievement")
                        .font(.system(.caption2, design: .monospaced).weight(.black))
                        .foregroundStyle(quest.isComplete ? BlockTheme.gold : BlockTheme.dimText)
                    Text(quest.title)
                        .font(.system(.headline, design: .monospaced).weight(.black))
                        .foregroundStyle(BlockTheme.text)
                        .strikethrough(quest.isComplete, color: BlockTheme.gold)
                        .lineLimit(2)
                    Text("+\(quest.rewardXP) XP  +\(quest.rewardCoins) coins")
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundStyle(BlockTheme.emerald)
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
        .padding(10)
        .background(quest.isComplete ? Color(red: 0.08, green: 0.19, blue: 0.11) : BlockTheme.deepStone)
        .overlay {
            Rectangle()
                .stroke(quest.isComplete ? BlockTheme.emerald : BlockTheme.stone, lineWidth: 3)
        }
        .shadow(color: .black.opacity(0.42), radius: 0, x: 5, y: 5)
    }
}

struct EditQuestSheet: View {
    let quest: Quest
    let onSave: (String, QuestDifficulty) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var difficulty: QuestDifficulty

    init(quest: Quest, onSave: @escaping (String, QuestDifficulty) -> Void) {
        self.quest = quest
        self.onSave = onSave
        _title = State(initialValue: quest.title)
        _difficulty = State(initialValue: quest.difficulty)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BlockWorldBackground()
                    .ignoresSafeArea()

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
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Edit Quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(title, difficulty) }
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
        .shadow(color: .black.opacity(0.5), radius: 0, x: 5, y: 5)
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
                .shadow(color: .black.opacity(0.6), radius: 0, x: 2, y: 2)
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
            .shadow(color: .black.opacity(0.46), radius: 0, x: 6, y: 6)
    }
}

extension View {
    func blockPanel() -> some View {
        modifier(BlockPanelModifier())
    }
}
