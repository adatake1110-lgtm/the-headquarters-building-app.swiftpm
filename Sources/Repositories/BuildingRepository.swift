import Foundation

/// ビルデータのリポジトリ
/// Firestoreとの通信を抽象化
@MainActor
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
        // CSVファイルからデータを読み込み
        loadFromCSV()
    }

    /// CSVファイルからビルデータを読み込み
    private func loadFromCSV() {
        do {
            buildings = try CSVImporter.importBuildings(from: "buildings")
            print("✅ ビルデータを\(buildings.count)件読み込みました")
        } catch {
            // CSVが見つからない場合はモックデータを使用
            print("⚠️ CSV読み込み失敗、モックデータを使用: \(error.localizedDescription)")
            buildings = Building.mockData
        }
    }

    /// CSVを再読み込み
    func reloadFromCSV() {
        loadFromCSV()
    }

    /// ビル一覧を取得
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
