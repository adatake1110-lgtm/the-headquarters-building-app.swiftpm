import Foundation

/// ビルデータのリポジトリ
/// Firestoreとの通信を抽象化
@Observable
final class BuildingRepository {
    /// シングルトンインスタンス
    static let shared = BuildingRepository()

    /// ビル一覧
    private(set) var buildings: [Building] = []

    /// 読み込み中かどうか
    private(set) var isLoading = false

    /// エラーメッセージ
    private(set) var errorMessage: String?

    private init() {
        // 初期データとしてモックデータを使用
        // TODO: Firebase統合時にFirestoreから取得
        buildings = Building.mockData
    }

    /// ビル一覧を取得
    @MainActor
    func fetchBuildings() async {
        isLoading = true
        errorMessage = nil

        // TODO: Firebase統合時に実装
        // 現在はモックデータを使用
        do {
            // Firestoreからの取得をシミュレート
            try await Task.sleep(nanoseconds: 500_000_000)
            buildings = Building.mockData
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// IDでビルを取得
    func getBuilding(by id: String) -> Building? {
        buildings.first { $0.buildingId == id }
    }

    /// ビル名で検索
    func searchBuildings(query: String) -> [Building] {
        if query.isEmpty {
            return buildings
        }
        return buildings.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    /// ビルに入居している企業一覧を取得
    func getCompanies(for buildingId: String) -> [Company] {
        CompanyRepository.shared.companies.filter { $0.buildingId == buildingId }
    }
}
