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
                Quest(title: "Gather morning focus", rewardXP: 35, rewardCoins: 15),
                Quest(title: "Craft one hard task", rewardXP: 25, rewardCoins: 10),
                Quest(title: "Place tomorrow's first block", rewardXP: 30, rewardCoins: 12)
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

    func deleteQuest(_ quest: Quest) {
        quests.removeAll { $0.id == quest.id }
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

enum BlockTheme {
    static let bedrock = Color(red: 0.06, green: 0.06, blue: 0.06)
    static let stone = Color(red: 0.29, green: 0.29, blue: 0.27)
    static let deepStone = Color(red: 0.13, green: 0.13, blue: 0.12)
    static let grass = Color(red: 0.23, green: 0.47, blue: 0.18)
    static let dirt = Color(red: 0.36, green: 0.22, blue: 0.12)
    static let gold = Color(red: 0.96, green: 0.78, blue: 0.22)
    static let emerald = Color(red: 0.22, green: 0.78, blue: 0.34)
    static let text = Color(red: 0.94, green: 0.92, blue: 0.82)
    static let dimText = Color(red: 0.66, green: 0.64, blue: 0.56)
}

struct ContentView: View {
    @StateObject private var store = QuestStore()
    @State private var newQuestTitle = ""
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
                        AddQuestBar(title: $newQuestTitle, isFocused: _isAddingQuest) {
                            addQuest()
                        }
                        QuestBoard(store: store) { quest in
                            completeQuest(quest)
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
        }
    }

    private func addQuest() {
        store.addQuest(title: newQuestTitle)
        newQuestTitle = ""
        isAddingQuest = false
    }

    private func completeQuest(_ quest: Quest) {
        let wasIncomplete = !quest.isComplete
        withAnimation(.snappy) {
            store.toggleQuest(quest)
        }

        if wasIncomplete {
            showAchievement(quest.title)
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
                ProgressTile(title: "CLEAR", value: "\(Int(store.completionRatio * 100))%")
            }
        }
        .padding(14)
        .blockPanel()
    }
}

struct AddQuestBar: View {
    @Binding var title: String
    @FocusState var isFocused: Bool
    let onAdd: () -> Void

    var body: some View {
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
        .padding(12)
        .blockPanel()
    }
}

struct QuestBoard: View {
    @ObservedObject var store: QuestStore
    let onToggle: (Quest) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(store.quests) { quest in
                QuestRow(quest: quest) {
                    onToggle(quest)
                } onDelete: {
                    withAnimation(.snappy) {
                        store.deleteQuest(quest)
                    }
                }
            }

            if store.quests.isEmpty {
                EmptyQuestView()
            }
        }
    }
}

struct QuestRow: View {
    let quest: Quest
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ItemSlot(
                    systemName: quest.isComplete ? "checkmark.seal.fill" : "square.grid.3x3.fill",
                    tint: quest.isComplete ? BlockTheme.emerald : BlockTheme.gold,
                    size: 54
                )
            }
            .buttonStyle(.plain)

            Button(action: onToggle) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(quest.isComplete ? "Achievement Get!" : "Locked Achievement")
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

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption.weight(.black))
                    .foregroundStyle(BlockTheme.dimText)
                    .frame(width: 34, height: 46)
            }
            .accessibilityLabel("Delete quest")
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

struct EmptyQuestView: View {
    var body: some View {
        VStack(spacing: 10) {
            ItemSlot(systemName: "flag.checkered", tint: BlockTheme.gold, size: 62)
            Text("All achievements cleared")
                .font(.system(.headline, design: .monospaced).weight(.black))
                .foregroundStyle(BlockTheme.text)
            Text("Add a new quest to keep mining progress.")
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
