import SwiftUI

/// アプリのエントリーポイント
@main
struct HQBuildingMapApp: App {
    /// アプリ状態
    @State private var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(appState)
                .preferredColorScheme(appState.preferredColorScheme)
        }
    }
}
