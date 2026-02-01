import Foundation

/// 企業モデル
/// Firestoreの`companies`コレクションに対応
struct Company: Identifiable, Codable, Hashable {
    var id: String { companyId }

    let companyId: String
    let name: String
    let industry: String
    let description: String
    let buildingId: String
    let postalCode: String
    let address: String
    let latitude: Double
    let longitude: Double
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case companyId = "company_id"
        case name
        case industry
        case description
        case buildingId = "building_id"
        case postalCode = "postal_code"
        case address
        case latitude
        case longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Mock Data
extension Company {
    static let mockData: [Company] = [
        Company(
            companyId: "company_001",
            name: "Google 日本法人",
            industry: "IT・インターネット",
            description: "世界最大の検索エンジンを提供するテクノロジー企業。クラウドサービス、広告事業、Android OSなど幅広い事業を展開。",
            buildingId: "building_001",
            postalCode: "106-6126",
            address: "東京都港区六本木6-10-1 六本木ヒルズ森タワー",
            latitude: 35.6604,
            longitude: 139.7292,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Company(
            companyId: "company_002",
            name: "楽天グループ株式会社",
            industry: "IT・インターネット",
            description: "ECサイト「楽天市場」を中心に、フィンテック、モバイル、デジタルコンテンツなど多角的に事業を展開。",
            buildingId: "building_001",
            postalCode: "158-0094",
            address: "東京都世田谷区玉川1-14-1",
            latitude: 35.6109,
            longitude: 139.6267,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Company(
            companyId: "company_003",
            name: "株式会社ミクシィ",
            industry: "IT・インターネット",
            description: "SNS「mixi」の運営やスマートフォンゲーム「モンスターストライク」の開発・運営を行う。",
            buildingId: "building_002",
            postalCode: "150-6136",
            address: "東京都渋谷区渋谷2-24-12 渋谷スクランブルスクエア",
            latitude: 35.6580,
            longitude: 139.7016,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Company(
            companyId: "company_004",
            name: "富士フイルム株式会社",
            industry: "精密機器・化学",
            description: "写真フィルムの製造から始まり、現在は医療機器、化粧品、高機能材料など幅広い分野で事業を展開。",
            buildingId: "building_003",
            postalCode: "107-0052",
            address: "東京都港区赤坂9-7-3",
            latitude: 35.6654,
            longitude: 139.7310,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}
