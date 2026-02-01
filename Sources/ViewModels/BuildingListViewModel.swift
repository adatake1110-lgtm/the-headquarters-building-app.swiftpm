import SwiftUI

/// ビル一覧画面のViewModel
@Observable
final class BuildingListViewModel {
    /// ビルリポジトリ
    private let buildingRepository = BuildingRepository.shared

    /// 検索クエリ
    var searchQuery = ""

    /// 読み込み中かどうか
    var isLoading: Bool {
        buildingRepository.isLoading
    }

    /// フィルタされたビル一覧
    var filteredBuildings: [Building] {
        buildingRepository.searchBuildings(query: searchQuery)
    }

    /// ビルデータを読み込む
    @MainActor
    func loadBuildings() async {
        await buildingRepository.fetchBuildings()
    }
}
