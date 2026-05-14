import SwiftUI

struct TaskRowView: View {
    let task: TodoTask
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .white.opacity(0.75))
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .foregroundStyle(.white)
                    .strikethrough(task.isCompleted)
                if !task.memo.isEmpty {
                    Text(task.memo)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(2)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(task.difficulty.displayName)
                    .font(.caption2)
                    .foregroundStyle(.yellow)
                Text("+\(task.xpReward) XP")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
            }
        }
        .padding(10)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .contextMenu {
            Button("Edit", action: onEdit)
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
}
