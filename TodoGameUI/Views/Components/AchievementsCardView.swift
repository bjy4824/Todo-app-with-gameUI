import SwiftUI

struct AchievementsCardView: View {
    let achievements: [Achievement]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Achievements")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(achievements) { achievement in
                HStack {
                    Image(systemName: achievement.icon)
                        .foregroundStyle(achievement.isUnlocked ? .yellow : .gray)
                    VStack(alignment: .leading) {
                        Text(achievement.title)
                            .foregroundStyle(.white)
                        Text(achievement.description)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Spacer()
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                }
                .padding(8)
                .background(.white.opacity(achievement.isUnlocked ? 0.13 : 0.06), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
    }
}
