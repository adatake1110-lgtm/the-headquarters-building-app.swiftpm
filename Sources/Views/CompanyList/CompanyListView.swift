import SwiftUI

/// 企業一覧画面
struct CompanyListView: View {
    /// ViewModel
    @State private var viewModel = CompanyListViewModel()

    /// アプリ状態
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            ForEach(viewModel.filteredCompanies) { company in
                NavigationLink(value: company) {
                    CompanyRowView(company: company)
                }
            }
        }
        .listStyle(.plain)
        .searchable(
            text: $viewModel.searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "企業名を検索"
        )
        .navigationTitle("企業一覧")
        .navigationDestination(for: Company.self) { company in
            CompanyDetailView(company: company)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.filteredCompanies.isEmpty {
                ContentUnavailableView(
                    "企業が見つかりません",
                    systemImage: "building.2",
                    description: Text("検索条件を変更してください")
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !appState.isPremium {
                AdBannerView()
            }
        }
        .task {
            await viewModel.loadCompanies()
        }
    }
}

/// 企業行ビュー
struct CompanyRowView: View {
    let company: Company

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(company.name)
                .font(.headline)

            HStack(spacing: 8) {
                Label(company.industry, systemImage: "tag")
                    .font(.caption)
                    .foregroundStyle(AppColors.primary)
            }

            Text(company.address)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        CompanyListView()
    }
    .environment(AppState.shared)
}
