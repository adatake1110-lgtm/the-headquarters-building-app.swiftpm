import SwiftUI

/// 管理者認証ViewModel
@MainActor
@Observable
final class AdminAuthViewModel {
    /// 認証サービス
    private let authService = AdminAuthService.shared

    /// メールアドレス
    var email = ""

    /// パスワード
    var password = ""

    /// ログイン処理中かどうか
    var isLoading: Bool {
        authService.isLoading
    }

    /// エラーメッセージ
    var errorMessage: String? {
        authService.errorMessage
    }

    /// ログイン中かどうか
    var isLoggedIn: Bool {
        authService.isAdminLoggedIn
    }

    /// 現在の管理者
    var currentAdmin: AdminUser? {
        authService.currentAdmin
    }

    /// 入力バリデーション
    var isValidInput: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    /// ログイン
    func login() async -> Bool {
        guard isValidInput else { return false }
        return await authService.login(email: email, password: password)
    }

    /// ログアウト
    func logout() async {
        await authService.logout()
    }

    /// 入力をクリア
    func clearInput() {
        email = ""
        password = ""
    }
}
