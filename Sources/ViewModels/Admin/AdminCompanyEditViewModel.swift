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
        "IT・通信",
        "金融・保険",
        "不動産・建設",
        "製造業",
        "小売・流通",
        "サービス",
        "メディア・広告",
        "コンサルティング",
        "エネルギー",
        "医療・ヘルスケア",
        "教育",
        "その他"
    ]

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
    }

    // MARK: - バリデーション

    /// 入力バリデーション
    var isValidInput: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !industry.isEmpty &&
        selectedBuildingId != nil &&
        Double(latitudeString) != nil &&
        Double(longitudeString) != nil
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
        if Double(latitudeString) == nil {
            return "緯度を正しく入力してください"
        }
        if Double(longitudeString) == nil {
            return "経度を正しく入力してください"
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
            // 企業データを作成
            _ = Company(
                companyId: originalCompany?.companyId ?? UUID().uuidString,
                name: name.trimmingCharacters(in: .whitespaces),
                industry: industry,
                description: description.trimmingCharacters(in: .whitespaces),
                buildingId: selectedBuildingId!,
                postalCode: postalCode.trimmingCharacters(in: .whitespaces),
                address: address.trimmingCharacters(in: .whitespaces),
                latitude: Double(latitudeString) ?? 0,
                longitude: Double(longitudeString) ?? 0,
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
