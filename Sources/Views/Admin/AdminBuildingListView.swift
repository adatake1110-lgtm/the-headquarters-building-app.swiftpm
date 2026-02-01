import SwiftUI

/// 管理者用ビル一覧画面
struct AdminBuildingListView: View {
    /// ViewModel
    @State private var viewModel = AdminBuildingListViewModel()

    /// 新規作成画面表示
    @State private var showNewBuildingSheet = false

    /// 編集中のビル
    @State private var editingBuilding: Building?

    var body: some View {
        List {
            ForEach(viewModel.filteredBuildings) { building in
                Button {
                    editingBuilding = building
                } label: {
                    AdminBuildingRowView(building: building)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewModel.confirmDelete(building)
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "ビル名で検索")
        .navigationTitle("ビル管理")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showNewBuildingSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.filteredBuildings.isEmpty {
                ContentUnavailableView(
                    "ビルがありません",
                    systemImage: "building.2",
                    description: Text("「＋」ボタンからビルを追加してください")
                )
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .sheet(isPresented: $showNewBuildingSheet) {
            AdminBuildingEditView(building: nil) {
                viewModel.loadBuildings()
            }
        }
        .sheet(item: $editingBuilding) { building in
            AdminBuildingEditView(building: building) {
                viewModel.loadBuildings()
            }
        }
        .alert("ビルを削除", isPresented: $viewModel.showDeleteConfirmation) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                if let building = viewModel.buildingToDelete {
                    Task {
                        _ = await viewModel.deleteBuilding(building)
                    }
                }
            }
        } message: {
            if let building = viewModel.buildingToDelete {
                Text("「\(building.name)」を削除しますか？\nこの操作は取り消せません。")
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

/// 管理者用ビル行ビュー
struct AdminBuildingRowView: View {
    let building: Building

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(building.name)
                .font(.headline)

            Text(building.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                if let floors = building.floorDescription {
                    Label(floors, systemImage: "building.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let height = building.heightDescription {
                    Label(height, systemImage: "arrow.up.and.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AdminBuildingListView()
    }
}
