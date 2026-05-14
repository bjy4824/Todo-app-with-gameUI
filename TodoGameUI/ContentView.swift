import SwiftUI

struct Quest: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var rewardXP: Int
    var rewardCoins: Int
    var isComplete: Bool

    init(id: UUID = UUID(), title: String, rewardXP: Int = 25, rewardCoins: Int = 10, isComplete: Bool = false) {
        self.id = id
        self.title = title
        self.rewardXP = rewardXP
        self.rewardCoins = rewardCoins
        self.isComplete = isComplete
    }
}

struct PlayerState: Codable, Equatable {
    var level: Int
    var xp: Int
    var coins: Int

    static let fresh = PlayerState(level: 1, xp: 0, coins: 0)

    var xpForCurrentLevel: Int {
        level * 100
    }

    var progress: Double {
        guard xpForCurrentLevel > 0 else { return 0 }
        return min(Double(xp) / Double(xpForCurrentLevel), 1)
    }
}

@MainActor
final class QuestStore: ObservableObject {
    @Published var quests: [Quest] {
        didSet { save() }
    }

    @Published var player: PlayerState {
        didSet { save() }
    }

    private let questsKey = "todo-quest.quests"
    private let playerKey = "todo-quest.player"

    init() {
        let decoder = JSONDecoder()
        if let questData = UserDefaults.standard.data(forKey: questsKey),
           let decodedQuests = try? decoder.decode([Quest].self, from: questData) {
            quests = decodedQuests
        } else {
            quests = [
                Quest(title: "Morning focus sprint", rewardXP: 35, rewardCoins: 15),
                Quest(title: "Clean up one messy task", rewardXP: 25, rewardCoins: 10),
                Quest(title: "Plan tomorrow's first move", rewardXP: 30, rewardCoins: 12)
            ]
        }

        if let playerData = UserDefaults.standard.data(forKey: playerKey),
           let decodedPlayer = try? decoder.decode(PlayerState.self, from: playerData) {
            player = decodedPlayer
        } else {
            player = .fresh
        }
    }

    var completedCount: Int {
        quests.filter(\.isComplete).count
    }

    var completionRatio: Double {
        guard !quests.isEmpty else { return 0 }
        return Double(completedCount) / Double(quests.count)
    }

    func addQuest(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        quests.insert(Quest(title: trimmedTitle), at: 0)
    }

    func toggleQuest(_ quest: Quest) {
        guard let index = quests.firstIndex(of: quest) else { return }
        quests[index].isComplete.toggle()

        if quests[index].isComplete {
            award(xp: quests[index].rewardXP, coins: quests[index].rewardCoins)
        } else {
            player.xp = max(0, player.xp - quests[index].rewardXP)
            player.coins = max(0, player.coins - quests[index].rewardCoins)
        }
    }

    func deleteQuest(at offsets: IndexSet) {
        quests.remove(atOffsets: offsets)
    }

    func resetDay() {
        quests = quests.map {
            var quest = $0
            quest.isComplete = false
            return quest
        }
    }

    private func award(xp: Int, coins: Int) {
        player.xp += xp
        player.coins += coins

        while player.xp >= player.xpForCurrentLevel {
            player.xp -= player.xpForCurrentLevel
            player.level += 1
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        if let questData = try? encoder.encode(quests) {
            UserDefaults.standard.set(questData, forKey: questsKey)
        }
        if let playerData = try? encoder.encode(player) {
            UserDefaults.standard.set(playerData, forKey: playerKey)
        }
    }
}

struct ContentView: View {
    @StateObject private var store = QuestStore()
    @State private var newQuestTitle = ""
    @FocusState private var isAddingQuest: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                ArenaBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        HeroPanel(store: store)
                        AddQuestBar(title: $newQuestTitle, isFocused: _isAddingQuest) {
                            store.addQuest(title: newQuestTitle)
                            newQuestTitle = ""
                            isAddingQuest = false
                        }
                        QuestBoard(store: store)
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Todo Quest")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.resetDay()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Reset daily quests")
                }
            }
        }
    }
}

struct ArenaBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.06, green: 0.08, blue: 0.10),
                Color(red: 0.08, green: 0.13, blue: 0.14),
                Color(red: 0.12, green: 0.09, blue: 0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct HeroPanel: View {
    @ObservedObject var store: QuestStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("DAILY RUN")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.secondary)
                    Text("Level \(store.player.level) Adventurer")
                        .font(.system(.title, design: .rounded).weight(.black))
                }

                Spacer()

                StatPill(systemName: "bitcoinsign.circle.fill", value: "\(store.player.coins)")
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("XP")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(store.player.xp) / \(store.player.xpForCurrentLevel)")
                        .font(.caption.monospacedDigit().weight(.bold))
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: store.player.progress)
                    .tint(Color(red: 0.17, green: 0.78, blue: 0.70))
                    .scaleEffect(x: 1, y: 1.8, anchor: .center)
            }

            HStack(spacing: 12) {
                ProgressTile(title: "Quests", value: "\(store.completedCount)/\(store.quests.count)")
                ProgressTile(title: "Clear", value: "\(Int(store.completionRatio * 100))%")
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
    }
}

struct AddQuestBar: View {
    @Binding var title: String
    @FocusState var isFocused: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TextField("Add a new quest", text: $title)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(onAdd)
                .textInputAutocapitalization(.sentences)
                .padding(.horizontal, 14)
                .frame(height: 52)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.headline.weight(.black))
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.17, green: 0.78, blue: 0.70))
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityLabel("Add quest")
        }
    }
}

struct QuestBoard: View {
    @ObservedObject var store: QuestStore

    var body: some View {
        VStack(spacing: 10) {
            ForEach(store.quests) { quest in
                QuestRow(quest: quest) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        store.toggleQuest(quest)
                    }
                }
            }
            .onDelete(perform: store.deleteQuest)

            if store.quests.isEmpty {
                EmptyQuestView()
            }
        }
    }
}

struct QuestRow: View {
    let quest: Quest
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(quest.isComplete ? Color(red: 0.17, green: 0.78, blue: 0.70) : .white.opacity(0.10))
                        .frame(width: 42, height: 42)

                    Image(systemName: quest.isComplete ? "checkmark" : "sparkle")
                        .font(.headline.weight(.black))
                        .foregroundStyle(quest.isComplete ? .black : .white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(quest.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                        .strikethrough(quest.isComplete, color: .white.opacity(0.8))
                    Text("+\(quest.rewardXP) XP  +\(quest.rewardCoins) coins")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(rowBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.white.opacity(0.10), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var rowBackground: Color {
        quest.isComplete ? Color(red: 0.12, green: 0.30, blue: 0.27).opacity(0.86) : Color.white.opacity(0.07)
    }
}

struct ProgressTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.black))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.monospacedDigit().weight(.black))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct StatPill: View {
    let systemName: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
            Text(value)
                .monospacedDigit()
        }
        .font(.headline.weight(.black))
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(Color(red: 0.96, green: 0.74, blue: 0.30), in: Capsule())
        .foregroundStyle(.black)
    }
}

struct EmptyQuestView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "flag.checkered")
                .font(.largeTitle)
            Text("No quests left")
                .font(.headline.weight(.black))
            Text("Add one task to start a new run.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
    }
}
