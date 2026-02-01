import Foundation

/// 企業データのリポジトリ
/// Firestoreとの通信を抽象化
@MainActor
@Observable
final class CompanyRepository {
    /// シングルトンインスタンス
    static let shared = CompanyRepository()

    /// 企業一覧
    private(set) var companies: [Company] = []

    /// 読み込み中かどうか
    private(set) var isLoading = false

    /// エラーメッセージ
    private(set) var errorMessage: String?

    private init() {
        // CSVファイルからデータを読み込み
        loadFromCSV()
    }

    /// CSVファイルから企業データを読み込み
    private func loadFromCSV() {
        do {
            companies = try CSVImporter.importCompanies(from: "companies")
            print("✅ 企業データを\(companies.count)件読み込みました")
        } catch {
            // CSVが見つからない場合はモックデータを使用
            print("⚠️ CSV読み込み失敗、モックデータを使用: \(error.localizedDescription)")
            companies = Company.mockData
        }
    }

    /// CSVを再読み込み
    func reloadFromCSV() {
        loadFromCSV()
    }

    /// 企業一覧を取得
    func fetchCompanies() async {
        isLoading = true
        errorMessage = nil

        // TODO: Firebase統合時に実装
        // 現在はモックデータを使用
        do {
            // Firestoreからの取得をシミュレート
            try await Task.sleep(nanoseconds: 500_000_000)
            companies = Company.mockData
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// IDで企業を取得
    func getCompany(by id: String) -> Company? {
        companies.first { $0.companyId == id }
    }

    /// 企業名で検索
    func searchCompanies(query: String) -> [Company] {
        if query.isEmpty {
            return companies
        }
        return companies.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    /// 業界で絞り込み
    func filterByIndustry(_ industry: String) -> [Company] {
        companies.filter { $0.industry == industry }
    }

    /// 全業界を取得
    var allIndustries: [String] {
        Array(Set(companies.map { $0.industry })).sorted()
    }
}
