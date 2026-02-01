import SwiftUI

/// ビル一覧画面
struct BuildingListView: View {
    /// ViewModel
    @State private var viewModel = BuildingListViewModel()

    /// アプリ状態
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            ForEach(viewModel.filteredBuildings) { building in
                NavigationLink(value: building) {
                    BuildingRowView(building: building)
                }
            }
        }
        .listStyle(.plain)
        .searchable(
            text: $viewModel.searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "ビル名を検索"
        )
        .navigationTitle("ビル一覧")
        .navigationDestination(for: Building.self) { building in
            BuildingDetailView(building: building)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.filteredBuildings.isEmpty {
                ContentUnavailableView(
                    "ビルが見つかりません",
                    systemImage: "building",
                    description: Text("検索条件を変更してください")
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            // 広告バナー（無料版のみ）
            if !appState.isPremium {
                AdBannerView()
            }
        }
        .task {
            await viewModel.loadBuildings()
        }
    }
}

/// ビル行ビュー
struct BuildingRowView: View {
    let building: Building

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(building.name)
                .font(.headline)

            Text(building.address)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let floorDesc = building.floorDescription {
                Text(floorDesc)
                    .font(.caption2)
                    .foregroundStyle(AppColors.primary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        BuildingListView()
    }
    .environment(AppState.shared)
}
