import StoreKit
import SwiftUI

/// 課金管理クラス
/// StoreKit 2を使用した買い切り課金の管理
@MainActor
@Observable
final class PurchaseManager {
    /// シングルトンインスタンス
    static let shared = PurchaseManager()

    /// 購入処理中かどうか
    var isPurchasing = false

    /// エラーメッセージ
    var errorMessage: String?

    /// 有料版を購入済みかどうか
    var isPremiumPurchased: Bool {
        AppState.shared.isPremium
    }

    private init() {
        // トランザクション監視を開始
        Task {
            await observeTransactionUpdates()
        }
    }

    /// 有料版を購入
    func purchasePremium() async {
        isPurchasing = true
        errorMessage = nil

        do {
            // プロダクト情報を取得
            let products = try await Product.products(for: [Constants.premiumProductId])

            guard let product = products.first else {
                errorMessage = "プロダクトが見つかりません"
                isPurchasing = false
                return
            }

            // 購入処理
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified:
                    // 購入成功
                    AppState.shared.isPremium = true
                case .unverified:
                    errorMessage = "購入の検証に失敗しました"
                }
            case .userCancelled:
                // ユーザーがキャンセル
                break
            case .pending:
                // 承認待ち
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isPurchasing = false
    }

    /// 購入を復元
    func restorePurchases() async {
        isPurchasing = true
        errorMessage = nil

        do {
            try await AppStore.sync()

            // 購入履歴を確認
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == Constants.premiumProductId {
                        AppState.shared.isPremium = true
                        break
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isPurchasing = false
    }

    /// トランザクション更新を監視
    private func observeTransactionUpdates() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                if transaction.productID == Constants.premiumProductId {
                    await MainActor.run {
                        AppState.shared.isPremium = true
                    }
                }
                await transaction.finish()
            }
        }
    }
}
