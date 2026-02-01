import SwiftUI

/// 設定画面のViewModel
@MainActor
@Observable
final class SettingsViewModel {
    /// アプリ状態
    private let appState = AppState.shared

    /// 購入マネージャー
    private let purchaseManager = PurchaseManager.shared

    /// 有料版かどうか
    var isPremium: Bool {
        appState.isPremium
    }

    /// 購入処理中かどうか
    var isPurchasing: Bool {
        purchaseManager.isPurchasing
    }

    /// エラーメッセージ
    var errorMessage: String? {
        purchaseManager.errorMessage
    }

    /// カラースキーム設定
    var colorSchemeSelection: Int {
        get {
            if let scheme = appState.preferredColorScheme {
                return scheme == .dark ? 2 : 1
            }
            return 0 // システム連動
        }
        set {
            switch newValue {
            case 1:
                appState.preferredColorScheme = .light
            case 2:
                appState.preferredColorScheme = .dark
            default:
                appState.preferredColorScheme = nil
            }
        }
    }

    /// お気に入りビル一覧
    var favoriteBuildings: [Building] {
        FavoriteRepository.shared.favoriteBuildings
    }

    /// お気に入り企業一覧
    var favoriteCompanies: [Company] {
        FavoriteRepository.shared.favoriteCompanies
    }

    /// お気に入り総数
    var totalFavoriteCount: Int {
        appState.totalFavoriteCount
    }

    /// お気に入り上限
    var favoriteLimit: Int {
        Constants.freeVersionFavoriteLimit
    }

    /// アプリバージョン
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    /// 有料版を購入
    func purchasePremium() async {
        await purchaseManager.purchasePremium()
    }

    /// 購入を復元
    func restorePurchases() async {
        await purchaseManager.restorePurchases()
    }
}
