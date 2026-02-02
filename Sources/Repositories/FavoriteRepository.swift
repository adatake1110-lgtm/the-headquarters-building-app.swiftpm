import Foundation

/// お気に入りデータのリポジトリ
@MainActor
@Observable
final class FavoriteRepository {
    /// シングルトンインスタンス
    static let shared = FavoriteRepository()

    private let appState = AppState.shared

    private init() {}

    /// ビルがお気に入りかどうか
    func isBuildingFavorite(_ buildingId: String) -> Bool {
        appState.favoriteBuildingIds.contains(buildingId)
    }

    /// 企業がお気に入りかどうか
    func isCompanyFavorite(_ companyId: String) -> Bool {
        appState.favoriteCompanyIds.contains(companyId)
    }

    /// ビルをお気に入りに追加/解除
    func toggleBuildingFavorite(_ buildingId: String) {
        if isBuildingFavorite(buildingId) {
            appState.favoriteBuildingIds.remove(buildingId)
        } else {
            appState.favoriteBuildingIds.insert(buildingId)
        }
    }

    /// 企業をお気に入りに追加/解除
    func toggleCompanyFavorite(_ companyId: String) {
        if isCompanyFavorite(companyId) {
            appState.favoriteCompanyIds.remove(companyId)
        } else {
            appState.favoriteCompanyIds.insert(companyId)
        }
    }

    /// お気に入りビル一覧を取得
    var favoriteBuildings: [Building] {
        let buildingRepo = BuildingRepository.shared
        return appState.favoriteBuildingIds.compactMap { buildingRepo.getBuilding(by: $0) }
    }

    /// お気に入り企業一覧を取得
    var favoriteCompanies: [Company] {
        let companyRepo = CompanyRepository.shared
        return appState.favoriteCompanyIds.compactMap { companyRepo.getCompany(by: $0) }
    }
}
