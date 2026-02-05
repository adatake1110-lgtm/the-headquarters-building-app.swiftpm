import SwiftUI

/// 管理者用企業編集ViewModel
@MainActor
@Observable
final class AdminCompanyEditViewModel {
    /// ビルリポジトリ
    private let buildingRepository = BuildingRepository.shared

    /// 編集モード（新規作成 or 編集）
    let isNewCompany: Bool

    /// 元の企業（編集時のみ）
    let originalCompany: Company?

    // MARK: - 入力フィールド

    /// 企業名
    var name = ""

    /// 業界
    var industry = ""

    /// 企業概要
    var description = ""

    /// 本社ビルID
    var selectedBuildingId: String?

    /// 郵便番号
    var postalCode = ""

    /// 住所
    var address = ""

    /// 緯度
    var latitudeString = ""

    /// 経度
    var longitudeString = ""

    /// 地図埋め込みHTML（Google Maps embed）
    var mapEmbed = ""

    /// ストリートビュー埋め込みHTML
    var streetviewEmbed = ""

    // MARK: - 状態

    /// 保存中かどうか
    var isSaving = false

    /// エラーメッセージ
    var errorMessage: String?

    /// 保存成功
    var saveSucceeded = false

    // MARK: - 選択肢

    /// ビル一覧（Picker用）
    var availableBuildings: [Building] {
        buildingRepository.buildings
    }

    /// 選択中のビル
    var selectedBuilding: Building? {
        guard let id = selectedBuildingId else { return nil }
        return buildingRepository.getBuilding(by: id)
    }

    /// 業界リスト
    let industryOptions = [
        "自動車・輸送用機器",
        "鉄鋼・金属・鉱業",
        "機械・プラント",
        "電子・電気機器",
        "精密・医療機器",
        "食品・農林・水産",
        "建設・住宅・インテリア",
        "繊維・化学・薬品・化粧品",
        "印刷・事務機器関連",
        "スポーツ・玩具",
        "その他メーカー",
        "総合商社",
        "専門商社",
        "都市銀行",
        "投資銀行",
        "信託銀行",
        "証券",
        "アセットマネジメント",
        "政府系・系統金融機関",
        "生保・損保",
        "クレジット",
        "リース",
        "消費者金融",
        "不動産",
        "鉄道・航空",
        "陸運・海運・物流",
        "電力・ガス・エネルギー",
        "医療・福祉",
        "教育",
        "人材サービス",
        "コンサルティング・調査",
        "FAS",
        "ベンチャーキャピタル",
        "フードサービス",
        "ホテル・旅行",
        "アミューズメント・レジャー",
        "その他サービス",
        "SIer",
        "ソフトウェア",
        "ゲーム",
        "インターネット",
        "通信",
        "放送",
        "新聞",
        "出版",
        "広告",
        "官公庁",
        "公社・団体",
        "百貨店・スーパー",
        "コンビニ",
        "専門店",
        "法律事務所",
        "会計事務所"
    ]

    // MARK: - 座標抽出

    /// 地図埋め込みHTMLから座標を抽出して緯度・経度に反映
    func extractCoordinatesFromMapEmbed() {
        let trimmed = mapEmbed.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let coords = GoogleMapsEmbedParser.extractCoordinates(from: trimmed) {
            latitudeString = String(coords.latitude)
            longitudeString = String(coords.longitude)
        }
    }

    // MARK: - 初期化

    init(company: Company? = nil) {
        if let company = company {
            isNewCompany = false
            originalCompany = company
            populateFields(from: company)
        } else {
            isNewCompany = true
            originalCompany = nil
        }
    }

    /// 企業情報をフィールドに反映
    private func populateFields(from company: Company) {
        name = company.name
        industry = company.industry
        description = company.description
        selectedBuildingId = company.buildingId
        postalCode = company.postalCode
        address = company.address
        latitudeString = String(company.latitude)
        longitudeString = String(company.longitude)
        streetviewEmbed = company.streetviewEmbed ?? ""
    }

    // MARK: - バリデーション

    /// 座標が有効かどうか（直接入力またはmap_embedから取得）
    private var hasValidCoordinates: Bool {
        if Double(latitudeString) != nil && Double(longitudeString) != nil {
            return true
        }
        let trimmed = mapEmbed.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty,
           GoogleMapsEmbedParser.extractCoordinates(from: trimmed) != nil {
            return true
        }
        return false
    }

    /// 入力バリデーション
    var isValidInput: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !industry.isEmpty &&
        selectedBuildingId != nil &&
        hasValidCoordinates
    }

    /// バリデーションエラーメッセージ
    var validationErrorMessage: String? {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return "企業名を入力してください"
        }
        if industry.isEmpty {
            return "業界を選択してください"
        }
        if selectedBuildingId == nil {
            return "本社ビルを選択してください"
        }
        if !hasValidCoordinates {
            return "緯度・経度を入力するか、地図埋め込みHTMLを入力してください"
        }
        return nil
    }

    // MARK: - ビル選択時の自動入力

    /// ビルを選択した時に住所情報を自動入力
    func onBuildingSelected() {
        guard let building = selectedBuilding else { return }

        // ビルの住所情報を自動入力
        if postalCode.isEmpty {
            postalCode = building.postalCode
        }
        if address.isEmpty {
            address = building.address
        }
        if latitudeString.isEmpty {
            latitudeString = String(building.latitude)
        }
        if longitudeString.isEmpty {
            longitudeString = String(building.longitude)
        }
    }

    // MARK: - 保存

    /// 企業を保存
    func save() async -> Bool {
        guard isValidInput else {
            errorMessage = validationErrorMessage
            return false
        }

        isSaving = true
        errorMessage = nil

        do {
            // 座標を決定（直接入力 or map_embedから抽出）
            var finalLatitude = Double(latitudeString) ?? 0
            var finalLongitude = Double(longitudeString) ?? 0
            if finalLatitude == 0 && finalLongitude == 0 {
                let trimmedEmbed = mapEmbed.trimmingCharacters(in: .whitespaces)
                if let coords = GoogleMapsEmbedParser.extractCoordinates(from: trimmedEmbed) {
                    finalLatitude = coords.latitude
                    finalLongitude = coords.longitude
                }
            }

            // 企業データを作成
            let trimmedStreetview = streetviewEmbed.trimmingCharacters(in: .whitespaces)
            _ = Company(
                companyId: originalCompany?.companyId ?? UUID().uuidString,
                name: name.trimmingCharacters(in: .whitespaces),
                industry: industry,
                description: description.trimmingCharacters(in: .whitespaces),
                buildingId: selectedBuildingId!,
                postalCode: postalCode.trimmingCharacters(in: .whitespaces),
                address: address.trimmingCharacters(in: .whitespaces),
                latitude: finalLatitude,
                longitude: finalLongitude,
                streetviewEmbed: trimmedStreetview.isEmpty ? nil : trimmedStreetview,
                createdAt: originalCompany?.createdAt ?? Date(),
                updatedAt: Date()
            )

            // Firestoreに保存（モック実装）
            // 実際の実装:
            // try await Firestore.firestore()
            //     .collection("companies")
            //     .document(company.companyId)
            //     .setData(company.toDictionary())

            // シミュレート遅延
            try await Task.sleep(nanoseconds: 500_000_000)

            isSaving = false
            saveSucceeded = true
            return true

        } catch {
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
            isSaving = false
            return false
        }
    }
}
