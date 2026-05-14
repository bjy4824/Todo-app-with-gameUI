import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var vm: GameViewModel
    @State private var showingNewQuest = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.indigo.opacity(0.8), .black], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        ProfileCardView(profile: vm.profile)
                        QuestListCardView(showingNewQuest: $showingNewQuest)
                        AchievementsCardView(achievements: vm.profile.achievements)
                    }
                    .padding()
                }
            }
            .navigationTitle("Quest Board")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewQuest = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingNewQuest) {
                TaskEditorView(mode: .new)
                    .environmentObject(vm)
            }
        }
    }
}
