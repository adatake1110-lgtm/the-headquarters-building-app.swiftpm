import SwiftUI

/// メインタブビュー
/// アプリの4つのタブを管理
struct MainTabView: View {
    /// 現在選択中のタブ
    @State private var selectedTab: AppTab = .map

    var body: some View {
        TabView(selection: $selectedTab) {
            // ビルマップタブ（初期表示）
            NavigationStack {
                BuildingMapView()
            }
            .tabItem {
                Label(AppTab.map.title, systemImage: AppTab.map.iconName)
            }
            .tag(AppTab.map)

            // 企業一覧タブ
            NavigationStack {
                CompanyListView()
            }
            .tabItem {
                Label(AppTab.companies.title, systemImage: AppTab.companies.iconName)
            }
            .tag(AppTab.companies)

            // ビル一覧タブ
            NavigationStack {
                BuildingListView()
            }
            .tabItem {
                Label(AppTab.buildings.title, systemImage: AppTab.buildings.iconName)
            }
            .tag(AppTab.buildings)

            // 設定タブ
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(AppTab.settings.title, systemImage: AppTab.settings.iconName)
            }
            .tag(AppTab.settings)
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    MainTabView()
        .environment(AppState.shared)
}
