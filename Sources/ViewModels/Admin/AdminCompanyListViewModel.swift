import SwiftUI

/// 管理者用企業一覧ViewModel
@MainActor
@Observable
final class AdminCompanyListViewModel {
    /// 企業リポジトリ
    private let repository = CompanyRepository.shared

    /// 企業一覧
    var companies: [Company] = []

    /// 検索クエリ
    var searchQuery = ""

    /// 読み込み中かどうか
    var isLoading = false

    /// エラーメッセージ
    var errorMessage: String?

    /// 削除確認用の企業
    var companyToDelete: Company?

    /// 削除確認アラート表示
    var showDeleteConfirmation = false

    /// フィルタリングされた企業一覧
    var filteredCompanies: [Company] {
        if searchQuery.isEmpty {
            return companies
        }
        return companies.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.industry.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    init() {
        loadCompanies()
    }

    /// 企業一覧を読み込み
    func loadCompanies() {
        isLoading = true
        errorMessage = nil

        // Firestoreから読み込み（モック実装ではRepositoryから取得）
        companies = repository.companies
        isLoading = false
    }

    /// 企業を削除
    /// - Parameter company: 削除する企業
    func deleteCompany(_ company: Company) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            // Firestoreから削除（モック実装）
            // 実際の実装:
            // try await Firestore.firestore()
            //     .collection("companies")
            //     .document(company.companyId)
            //     .delete()

            // シミュレート遅延
            try await Task.sleep(nanoseconds: 500_000_000)

            // ローカルリストから削除
            companies.removeAll { $0.id == company.id }

            isLoading = false
            return true

        } catch {
            errorMessage = "削除に失敗しました: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    /// 削除確認を表示
    func confirmDelete(_ company: Company) {
        companyToDelete = company
        showDeleteConfirmation = true
    }

    /// リフレッシュ
    func refresh() async {
        // Firestoreから再読み込み
        loadCompanies()
    }
}
