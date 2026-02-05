import SwiftUI

/// アプリ全体の状態を管理するクラス
/// iOS 17以降の@Observableマクロを使用
@MainActor
@Observable
final class AppState {
    /// シングルトンインスタンス
    static let shared = AppState()

    /// ダークモード設定
    var preferredColorScheme: ColorScheme? {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: "colorScheme") else {
                return nil // システム連動
            }
            return rawValue == "dark" ? .dark : .light
        }
        set {
            if let scheme = newValue {
                UserDefaults.standard.set(scheme == .dark ? "dark" : "light", forKey: "colorScheme")
            } else {
                UserDefaults.standard.removeObject(forKey: "colorScheme")
            }
        }
    }

    /// 地図初期表示エリア（緯度）
    var defaultMapLatitude: Double {
        get {
            let value = UserDefaults.standard.double(forKey: "defaultMapLatitude")
            return value == 0 ? Constants.defaultLatitude : value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "defaultMapLatitude")
        }
    }

    /// 地図初期表示エリア（経度）
    var defaultMapLongitude: Double {
        get {
            let value = UserDefaults.standard.double(forKey: "defaultMapLongitude")
            return value == 0 ? Constants.defaultLongitude : value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "defaultMapLongitude")
        }
    }

    /// お気に入りビルIDリスト
    var favoriteBuildingIds: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: "favoriteBuildingIds") ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: "favoriteBuildingIds")
        }
    }

    /// お気に入り企業IDリスト
    var favoriteCompanyIds: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: "favoriteCompanyIds") ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: "favoriteCompanyIds")
        }
    }

    /// お気に入り総数
    var totalFavoriteCount: Int {
        favoriteBuildingIds.count + favoriteCompanyIds.count
    }

    private init() {}
}
