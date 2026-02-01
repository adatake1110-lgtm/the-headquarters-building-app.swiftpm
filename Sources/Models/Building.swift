import Foundation

/// ビルモデル
/// Firestoreの`buildings`コレクションに対応
struct Building: Identifiable, Codable, Hashable {
    var id: String { buildingId }

    let buildingId: String
    let name: String
    let postalCode: String
    let address: String
    let latitude: Double
    let longitude: Double
    let height: Double?
    let floorsAbove: Int?
    let floorsBelow: Int?
    let architect: String?
    let constructor: String?
    let imageUrls: [String]
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case buildingId = "building_id"
        case name
        case postalCode = "postal_code"
        case address
        case latitude
        case longitude
        case height
        case floorsAbove = "floors_above"
        case floorsBelow = "floors_below"
        case architect
        case constructor
        case imageUrls = "image_urls"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// 階数表示用フォーマット（例：地上52階・地下5階）
    var floorDescription: String? {
        var parts: [String] = []
        if let above = floorsAbove {
            parts.append("地上\(above)階")
        }
        if let below = floorsBelow {
            parts.append("地下\(below)階")
        }
        return parts.isEmpty ? nil : parts.joined(separator: "・")
    }

    /// 高さ表示用フォーマット（例：238.0m）
    var heightDescription: String? {
        guard let height = height else { return nil }
        return String(format: "%.1fm", height)
    }
}

// MARK: - Mock Data
extension Building {
    static let mockData: [Building] = [
        Building(
            buildingId: "building_001",
            name: "六本木ヒルズ森タワー",
            postalCode: "106-6108",
            address: "東京都港区六本木6-10-1",
            latitude: 35.6604,
            longitude: 139.7292,
            height: 238.0,
            floorsAbove: 54,
            floorsBelow: 6,
            architect: "コーン・ペダーセン・フォックス",
            constructor: "大林組",
            imageUrls: [],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Building(
            buildingId: "building_002",
            name: "渋谷スクランブルスクエア",
            postalCode: "150-6139",
            address: "東京都渋谷区渋谷2-24-12",
            latitude: 35.6580,
            longitude: 139.7016,
            height: 229.7,
            floorsAbove: 47,
            floorsBelow: 7,
            architect: "日建設計・隈研吾建築都市設計事務所・SANAA",
            constructor: "東急建設・大成建設JV",
            imageUrls: [],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Building(
            buildingId: "building_003",
            name: "東京ミッドタウン",
            postalCode: "107-0052",
            address: "東京都港区赤坂9-7-1",
            latitude: 35.6654,
            longitude: 139.7310,
            height: 248.1,
            floorsAbove: 54,
            floorsBelow: 5,
            architect: "スキッドモア・オーウィングズ・アンド・メリル",
            constructor: "竹中工務店",
            imageUrls: [],
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}
