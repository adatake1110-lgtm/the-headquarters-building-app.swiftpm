import SwiftUI
import PhotosUI

/// 管理者用ビル編集ViewModel
@MainActor
@Observable
final class AdminBuildingEditViewModel {
    /// ストレージサービス
    private let storageService = StorageService.shared

    /// 編集モード（新規作成 or 編集）
    let isNewBuilding: Bool

    /// 元のビル（編集時のみ）
    let originalBuilding: Building?

    // MARK: - 入力フィールド

    /// ビル名
    var name = ""

    /// 郵便番号
    var postalCode = ""

    /// 住所
    var address = ""

    /// 緯度
    var latitudeString = ""

    /// 経度
    var longitudeString = ""

    /// 高さ
    var heightString = ""

    /// 地上階数
    var floorsAboveString = ""

    /// 地下階数
    var floorsBelowString = ""

    /// 設計
    var architect = ""

    /// 施工
    var constructor = ""

    /// 着工年月（yyyymm形式）
    var constructionStart = ""

    /// 竣工年月（yyyymm形式）
    var completion = ""

    /// 説明文
    var description = ""

    /// 既存の画像URL
    var existingImageUrls: [String] = []

    /// 新規追加画像
    var newImages: [UIImage] = []

    /// 削除予定の画像URL
    var imagesToDelete: [String] = []

    // MARK: - 状態

    /// 保存中かどうか
    var isSaving = false

    /// エラーメッセージ
    var errorMessage: String?

    /// 保存成功
    var saveSucceeded = false

    /// 画像ピッカー表示
    var showImagePicker = false

    /// 選択された写真アイテム
    var selectedPhotoItems: [PhotosPickerItem] = []

    // MARK: - 初期化

    init(building: Building? = nil) {
        if let building = building {
            isNewBuilding = false
            originalBuilding = building
            populateFields(from: building)
        } else {
            isNewBuilding = true
            originalBuilding = nil
        }
    }

    /// ビル情報をフィールドに反映
    private func populateFields(from building: Building) {
        name = building.name
        postalCode = building.postalCode
        address = building.address
        latitudeString = String(building.latitude)
        longitudeString = String(building.longitude)
        heightString = building.height.map { String($0) } ?? ""
        floorsAboveString = building.floorsAbove.map { String($0) } ?? ""
        floorsBelowString = building.floorsBelow.map { String($0) } ?? ""
        architect = building.architect ?? ""
        constructor = building.constructor ?? ""
        constructionStart = building.constructionStart ?? ""
        completion = building.completion ?? ""
        existingImageUrls = building.imageUrls
    }

    // MARK: - バリデーション

    /// 入力バリデーション
    var isValidInput: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(latitudeString) != nil &&
        Double(longitudeString) != nil
    }

    /// バリデーションエラーメッセージ
    var validationErrorMessage: String? {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return "ビル名を入力してください"
        }
        if address.trimmingCharacters(in: .whitespaces).isEmpty {
            return "住所を入力してください"
        }
        if Double(latitudeString) == nil {
            return "緯度を正しく入力してください"
        }
        if Double(longitudeString) == nil {
            return "経度を正しく入力してください"
        }
        return nil
    }

    // MARK: - 画像操作

    /// 画像を追加
    func addImage(_ image: UIImage) {
        // リサイズして追加
        let resized = storageService.resizeImage(image)
        newImages.append(resized)
    }

    /// 新規画像を削除
    func removeNewImage(at index: Int) {
        guard index < newImages.count else { return }
        newImages.remove(at: index)
    }

    /// 既存画像を削除予定に追加
    func markImageForDeletion(_ url: String) {
        existingImageUrls.removeAll { $0 == url }
        imagesToDelete.append(url)
    }

    /// PhotosPickerから画像を読み込み
    func loadImages(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                addImage(image)
            }
        }
        selectedPhotoItems = []
    }

    // MARK: - 保存

    /// ビルを保存
    func save() async -> Bool {
        guard isValidInput else {
            errorMessage = validationErrorMessage
            return false
        }

        isSaving = true
        errorMessage = nil

        do {
            // 新規画像をアップロード
            var allImageUrls = existingImageUrls
            if !newImages.isEmpty {
                let buildingId = originalBuilding?.buildingId ?? UUID().uuidString
                for (index, image) in newImages.enumerated() {
                    if let imageData = storageService.convertToJPEG(image: image) {
                        let path = "buildings/\(buildingId)/image_\(Date().timeIntervalSince1970)_\(index).jpg"
                        let url = try await storageService.uploadImage(imageData: imageData, path: path)
                        allImageUrls.append(url)
                    }
                }
            }

            // 削除予定の画像を削除
            for url in imagesToDelete {
                if let path = storageService.extractPath(from: url) {
                    try? await storageService.deleteImage(path: path)
                }
            }

            // ビルデータを作成
            _ = Building(
                buildingId: originalBuilding?.buildingId ?? UUID().uuidString,
                name: name.trimmingCharacters(in: .whitespaces),
                postalCode: postalCode.trimmingCharacters(in: .whitespaces),
                address: address.trimmingCharacters(in: .whitespaces),
                latitude: Double(latitudeString) ?? 0,
                longitude: Double(longitudeString) ?? 0,
                height: Double(heightString),
                floorsAbove: Int(floorsAboveString),
                floorsBelow: Int(floorsBelowString),
                architect: architect.isEmpty ? nil : architect,
                constructor: constructor.isEmpty ? nil : constructor,
                constructionStart: constructionStart.isEmpty ? nil : constructionStart,
                completion: completion.isEmpty ? nil : completion,
                imageUrls: allImageUrls,
                streetviewEmbed: originalBuilding?.streetviewEmbed,
                createdAt: originalBuilding?.createdAt ?? Date(),
                updatedAt: Date()
            )

            // Firestoreに保存（モック実装）
            // 実際の実装:
            // try await Firestore.firestore()
            //     .collection("buildings")
            //     .document(building.buildingId)
            //     .setData(building.toDictionary())

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
