import SwiftUI

/// アプリ全体で使用する定数
enum Constants {
    /// アプリ名
    static let appName = "本社ビルマップ"

    /// 無料版のお気に入り登録上限
    static let freeVersionFavoriteLimit = 10

    /// 有料版の価格
    static let premiumPrice = 500

    /// 有料版のプロダクトID
    static let premiumProductId = "com.example.hqbuildingmap.premium"

    /// デフォルトの地図中心座標（東京駅）
    static let defaultLatitude = 35.6812
    static let defaultLongitude = 139.7671
    static let defaultZoomLevel = 12.0
}

/// アプリのカラーテーマ
enum AppColors {
    /// プライマリカラー（ブルー）
    static let primary = Color.blue

    /// セカンダリカラー
    static let secondary = Color.blue.opacity(0.7)

    /// 背景色
    static let background = Color(.systemBackground)

    /// カード背景色
    static let cardBackground = Color(.secondarySystemBackground)

    /// テキストカラー
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
}

/// タブの種類
enum AppTab: Int, CaseIterable {
    case map = 0
    case companies
    case buildings
    case settings

    var title: String {
        switch self {
        case .map: return "ビルマップ"
        case .companies: return "企業一覧"
        case .buildings: return "ビル一覧"
        case .settings: return "設定"
        }
    }

    var iconName: String {
        switch self {
        case .map: return "map"
        case .companies: return "building.2"
        case .buildings: return "building"
        case .settings: return "gearshape"
        }
    }
}
