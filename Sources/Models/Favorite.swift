import Foundation

/// お気に入りの対象タイプ
enum FavoriteTargetType: String, Codable {
    case building
    case company
}

/// お気に入りモデル
/// Firestoreの`favorites`コレクションに対応
struct Favorite: Identifiable, Codable, Hashable {
    var id: String { "\(userId)_\(targetType.rawValue)_\(targetId)" }

    let favoriteId: String
    let userId: String
    let targetType: FavoriteTargetType
    let targetId: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case favoriteId = "favorite_id"
        case userId = "user_id"
        case targetType = "target_type"
        case targetId = "target_id"
        case createdAt = "created_at"
    }
}
