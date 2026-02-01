import Foundation
import SwiftUI

/// 管理者認証状態
enum AdminAuthState: Equatable {
    case unknown
    case notAuthenticated
    case authenticated(AdminUser)
}

/// 管理者ユーザー情報
struct AdminUser: Equatable, Identifiable {
    let id: String
    let email: String
    let displayName: String?
}

/// 管理者認証サービス
/// Firebase Authを使用した管理者認証を管理
/// 注意: Swift PlaygroundsではFirebase SDKが使用できないため、
///       モック実装となっています。Xcodeプロジェクトに移行後、
///       実際のFirebase Auth SDKに置き換えてください。
@MainActor
@Observable
final class AdminAuthService {
    /// シングルトンインスタンス
    static let shared = AdminAuthService()

    /// 認証状態
    private(set) var authState: AdminAuthState = .unknown

    /// ログイン処理中かどうか
    var isLoading = false

    /// エラーメッセージ
    var errorMessage: String?

    /// 管理者としてログイン中かどうか
    var isAdminLoggedIn: Bool {
        if case .authenticated = authState {
            return true
        }
        return false
    }

    /// 現在の管理者ユーザー
    var currentAdmin: AdminUser? {
        if case .authenticated(let user) = authState {
            return user
        }
        return nil
    }

    private init() {
        // 認証状態を復元
        Task {
            await restoreAuthState()
        }
    }

    /// 認証状態を復元
    private func restoreAuthState() async {
        // UserDefaultsから保存された認証情報を復元
        if let savedUserId = UserDefaults.standard.string(forKey: "admin_user_id"),
           let savedEmail = UserDefaults.standard.string(forKey: "admin_user_email") {
            // admin_usersコレクションをチェック（モック実装）
            if await isAdminUser(userId: savedUserId) {
                let displayName = UserDefaults.standard.string(forKey: "admin_user_name")
                authState = .authenticated(AdminUser(
                    id: savedUserId,
                    email: savedEmail,
                    displayName: displayName
                ))
                return
            }
        }
        authState = .notAuthenticated
    }

    /// 管理者ログイン
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    /// - Returns: ログイン成功かどうか
    func login(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            // Firebase Auth でログイン（モック実装）
            // 実際の実装では Auth.auth().signIn(withEmail:password:) を使用
            let userId = try await signInWithFirebase(email: email, password: password)

            // admin_users コレクションをチェック
            guard await isAdminUser(userId: userId) else {
                errorMessage = "管理者権限がありません"
                isLoading = false
                // ログインしたがadminではないのでサインアウト
                await signOutFromFirebase()
                return false
            }

            // 認証成功
            let adminUser = AdminUser(id: userId, email: email, displayName: nil)
            authState = .authenticated(adminUser)

            // 認証情報を保存
            saveAuthState(adminUser)

            isLoading = false
            return true

        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    /// ログアウト
    func logout() async {
        isLoading = true

        // Firebase Auth からサインアウト
        await signOutFromFirebase()

        // 保存された認証情報をクリア
        clearSavedAuthState()

        authState = .notAuthenticated
        isLoading = false
    }

    /// 認証情報を保存
    private func saveAuthState(_ user: AdminUser) {
        UserDefaults.standard.set(user.id, forKey: "admin_user_id")
        UserDefaults.standard.set(user.email, forKey: "admin_user_email")
        UserDefaults.standard.set(user.displayName, forKey: "admin_user_name")
    }

    /// 保存された認証情報をクリア
    private func clearSavedAuthState() {
        UserDefaults.standard.removeObject(forKey: "admin_user_id")
        UserDefaults.standard.removeObject(forKey: "admin_user_email")
        UserDefaults.standard.removeObject(forKey: "admin_user_name")
    }

    // MARK: - Firebase Auth モック実装
    // 以下はモック実装です。Xcodeプロジェクトに移行後、
    // 実際のFirebase Auth SDKに置き換えてください。

    /// Firebase Auth でサインイン（モック）
    private func signInWithFirebase(email: String, password: String) async throws -> String {
        // シミュレート: ネットワーク遅延
        try await Task.sleep(nanoseconds: 500_000_000)

        // モック: テスト用管理者アカウント
        // 本番環境では削除し、実際のFirebase Authを使用
        if email == "admin@example.com" && password == "admin123" {
            return "mock_admin_uid_001"
        }

        throw AdminAuthError.invalidCredentials
    }

    /// Firebase Auth からサインアウト（モック）
    private func signOutFromFirebase() async {
        // 実際の実装: try? Auth.auth().signOut()
    }

    /// admin_users コレクションをチェック（モック）
    private func isAdminUser(userId: String) async -> Bool {
        // 実際の実装:
        // let doc = try await Firestore.firestore()
        //     .collection("admin_users")
        //     .document(userId)
        //     .getDocument()
        // return doc.exists

        // モック: テスト用
        return userId == "mock_admin_uid_001"
    }
}

/// 管理者認証エラー
enum AdminAuthError: LocalizedError {
    case invalidCredentials
    case notAdmin
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "メールアドレスまたはパスワードが正しくありません"
        case .notAdmin:
            return "管理者権限がありません"
        case .networkError:
            return "ネットワークエラーが発生しました"
        }
    }
}
