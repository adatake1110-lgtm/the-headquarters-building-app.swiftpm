import SwiftUI

/// 企業一覧画面のViewModel
@Observable
final class CompanyListViewModel {
    /// 企業リポジトリ
    private let companyRepository = CompanyRepository.shared

    /// 検索クエリ
    var searchQuery = ""

    /// 読み込み中かどうか
    var isLoading: Bool {
        companyRepository.isLoading
    }

    /// フィルタされた企業一覧
    var filteredCompanies: [Company] {
        companyRepository.searchCompanies(query: searchQuery)
    }

    /// 全業界リスト
    var allIndustries: [String] {
        companyRepository.allIndustries
    }

    /// 企業データを読み込む
    @MainActor
    func loadCompanies() async {
        await companyRepository.fetchCompanies()
    }
}
