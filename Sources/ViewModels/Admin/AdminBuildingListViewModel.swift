import SwiftUI

/// 管理者用ビル一覧ViewModel
@MainActor
@Observable
final class AdminBuildingListViewModel {
    /// ビルリポジトリ
    private let repository = BuildingRepository.shared

    /// ビル一覧
    var buildings: [Building] = []

    /// 検索クエリ
    var searchQuery = ""

    /// 読み込み中かどうか
    var isLoading = false

    /// エラーメッセージ
    var errorMessage: String?

    /// 削除確認用のビル
    var buildingToDelete: Building?

    /// 削除確認アラート表示
    var showDeleteConfirmation = false

    /// フィルタリングされたビル一覧
    var filteredBuildings: [Building] {
        if searchQuery.isEmpty {
            return buildings
        }
        return buildings.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.address.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    init() {
        loadBuildings()
    }

    /// ビル一覧を読み込み
    func loadBuildings() {
        isLoading = true
        errorMessage = nil

        // Firestoreから読み込み（モック実装ではRepositoryから取得）
        buildings = repository.buildings
        isLoading = false
    }

    /// ビルを削除
    /// - Parameter building: 削除するビル
    func deleteBuilding(_ building: Building) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            // Firestoreから削除（モック実装）
            // 実際の実装:
            // try await Firestore.firestore()
            //     .collection("buildings")
            //     .document(building.buildingId)
            //     .delete()

            // シミュレート遅延
            try await Task.sleep(nanoseconds: 500_000_000)

            // ローカルリストから削除
            buildings.removeAll { $0.id == building.id }

            isLoading = false
            return true

        } catch {
            errorMessage = "削除に失敗しました: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    /// 削除確認を表示
    func confirmDelete(_ building: Building) {
        buildingToDelete = building
        showDeleteConfirmation = true
    }

    /// リフレッシュ
    func refresh() async {
        // Firestoreから再読み込み
        loadBuildings()
    }
}
