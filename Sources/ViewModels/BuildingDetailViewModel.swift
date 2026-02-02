import SwiftUI
import MapKit

/// ビル詳細画面のViewModel
@MainActor
@Observable
final class BuildingDetailViewModel {
    /// ビル
    let building: Building

    /// お気に入りリポジトリ
    private let favoriteRepository = FavoriteRepository.shared

    /// 入居企業一覧
    var tenantCompanies: [Company] {
        BuildingRepository.shared.getCompanies(for: building.buildingId)
    }

    /// お気に入り状態
    var isFavorite: Bool {
        favoriteRepository.isBuildingFavorite(building.buildingId)
    }

    /// マップリージョン
    var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: building.latitude,
                longitude: building.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }

    init(building: Building) {
        self.building = building
    }

    /// お気に入りをトグル
    func toggleFavorite() {
        favoriteRepository.toggleBuildingFavorite(building.buildingId)
    }
}
