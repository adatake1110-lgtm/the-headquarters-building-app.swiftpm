import SwiftUI
import MapKit

/// 企業詳細画面のViewModel
@Observable
final class CompanyDetailViewModel {
    /// 企業
    let company: Company

    /// お気に入りリポジトリ
    private let favoriteRepository = FavoriteRepository.shared

    /// 本社ビル
    var headquartersBuilding: Building? {
        BuildingRepository.shared.getBuilding(by: company.buildingId)
    }

    /// お気に入り状態
    var isFavorite: Bool {
        favoriteRepository.isCompanyFavorite(company.companyId)
    }

    /// マップリージョン
    var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: company.latitude,
                longitude: company.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    }

    init(company: Company) {
        self.company = company
    }

    /// お気に入りをトグル
    func toggleFavorite() -> Bool {
        favoriteRepository.toggleCompanyFavorite(company.companyId)
    }
}
