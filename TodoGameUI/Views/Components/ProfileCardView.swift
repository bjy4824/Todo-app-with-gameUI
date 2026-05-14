import SwiftUI

struct ProfileCardView: View {
    let profile: PlayerProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 48))
                    .foregroundStyle(.yellow)

                VStack(alignment: .leading) {
                    Text(profile.name)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("Level \(profile.level) Hero")
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Text("🔥 \(profile.dailyStreak)")
                    .font(.headline)
                    .foregroundStyle(.orange)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("XP Progress")
                    .foregroundStyle(.white.opacity(0.85))
                    .font(.caption)
                ProgressView(value: profile.progressToNextLevel)
                    .tint(.green)
                Text("\(profile.xpIntoCurrentLevel) / \(profile.xpNeededForNextLevel) XP")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.85))
            }

            HStack {
                statTile(title: "Total XP", value: "\(profile.totalXP)")
                statTile(title: "Quests", value: "\(profile.completedTasksCount)")
                statTile(title: "Streak", value: "\(profile.dailyStreak)d")
            }
        }
        .padding()
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
    }

    private func statTile(title: String, value: String) -> some View {
        VStack {
            Text(value).bold().foregroundStyle(.white)
            Text(title).font(.caption2).foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}
