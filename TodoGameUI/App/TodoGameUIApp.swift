import SwiftUI

@main
struct TodoGameUIApp: App {
    @StateObject private var gameViewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(gameViewModel)
        }
    }
}
