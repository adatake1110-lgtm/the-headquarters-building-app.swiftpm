import SwiftUI

/// 管理者用企業一覧画面
struct AdminCompanyListView: View {
    /// ViewModel
    @State private var viewModel = AdminCompanyListViewModel()

    /// 新規作成画面表示
    @State private var showNewCompanySheet = false

    /// 編集中の企業
    @State private var editingCompany: Company?

    var body: some View {
        List {
            ForEach(viewModel.filteredCompanies) { company in
                Button {
                    editingCompany = company
                } label: {
                    AdminCompanyRowView(company: company)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewModel.confirmDelete(company)
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "企業名で検索")
        .navigationTitle("企業管理")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showNewCompanySheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.filteredCompanies.isEmpty {
                ContentUnavailableView(
                    "企業がありません",
                    systemImage: "briefcase",
                    description: Text("「＋」ボタンから企業を追加してください")
                )
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .sheet(isPresented: $showNewCompanySheet) {
            AdminCompanyEditView(company: nil) {
                viewModel.loadCompanies()
            }
        }
        .sheet(item: $editingCompany) { company in
            AdminCompanyEditView(company: company) {
                viewModel.loadCompanies()
            }
        }
        .alert("企業を削除", isPresented: $viewModel.showDeleteConfirmation) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                if let company = viewModel.companyToDelete {
                    Task {
                        _ = await viewModel.deleteCompany(company)
                    }
                }
            }
        } message: {
            if let company = viewModel.companyToDelete {
                Text("「\(company.name)」を削除しますか？\nこの操作は取り消せません。")
            }
        }
        .alert("エラー", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

/// 管理者用企業行ビュー
struct AdminCompanyRowView: View {
    let company: Company

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(company.name)
                .font(.headline)

            Text(company.industry)
                .font(.subheadline)
                .foregroundStyle(AppColors.primary)

            Text(company.address)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AdminCompanyListView()
    }
}
