import SwiftUI

struct TaskEditorView: View {
    enum Mode {
        case new
        case edit(TodoTask)
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: GameViewModel

    let mode: Mode

    @State private var title = ""
    @State private var memo = ""
    @State private var difficulty: TaskDifficulty = .normal
    @State private var xpReward = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Quest Details") {
                    TextField("Title", text: $title)
                    TextField("Memo", text: $memo, axis: .vertical)
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(TaskDifficulty.allCases) { value in
                            Text(value.displayName).tag(value)
                        }
                    }
                    TextField("XP Reward", text: $xpReward)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle(modeTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: fillIfEdit)
        }
    }

    private var modeTitle: String {
        switch mode {
        case .new: return "New Quest"
        case .edit: return "Edit Quest"
        }
    }

    private func fillIfEdit() {
        guard case let .edit(task) = mode else {
            xpReward = "\(difficulty.defaultXP)"
            return
        }
        title = task.title
        memo = task.memo
        difficulty = task.difficulty
        xpReward = "\(task.xpReward)"
    }

    private func save() {
        let parsedXP = Int(xpReward)
        switch mode {
        case .new:
            vm.addTask(title: title, memo: memo, difficulty: difficulty, xpReward: parsedXP)
        case let .edit(task):
            vm.updateTask(task, title: title, memo: memo, difficulty: difficulty, xpReward: parsedXP)
        }
        dismiss()
    }
}
