import SwiftUI

struct QuestListCardView: View {
    @EnvironmentObject private var vm: GameViewModel
    @Binding var showingNewQuest: Bool
    @State private var editingTask: TodoTask?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Active Quests").font(.headline).foregroundStyle(.white)
                Spacer()
                Button("New Quest") { showingNewQuest = true }
                    .font(.caption.bold())
            }

            if vm.activeTasks.isEmpty {
                Text("No active quests. Add one to start earning XP.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
            } else {
                ForEach(vm.activeTasks) { task in
                    TaskRowView(task: task, onToggle: { vm.toggleTaskCompletion(task) }, onEdit: {
                        editingTask = task
                    }, onDelete: {
                        vm.deleteTask(task)
                    })
                }
            }

            if !vm.completedTasks.isEmpty {
                Divider().overlay(.white.opacity(0.2))
                Text("Completed").font(.subheadline.bold()).foregroundStyle(.white.opacity(0.85))
                ForEach(vm.completedTasks) { task in
                    TaskRowView(task: task, onToggle: { vm.toggleTaskCompletion(task) }, onEdit: {
                        editingTask = task
                    }, onDelete: {
                        vm.deleteTask(task)
                    })
                }
            }
        }
        .padding()
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
        .sheet(item: $editingTask) { task in
            TaskEditorView(mode: .edit(task))
                .environmentObject(vm)
        }
    }
}
