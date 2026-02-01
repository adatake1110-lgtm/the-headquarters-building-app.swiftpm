import Foundation
import SwiftUI

/// 画像アップロード進捗
struct UploadProgress: Identifiable {
    let id = UUID()
    var progress: Double
    var isCompleted: Bool
    var url: String?
    var error: Error?
}

/// Firebase Storage サービス
/// 画像のアップロード・削除を管理
/// 注意: Swift PlaygroundsではFirebase SDKが使用できないため、
///       モック実装となっています。Xcodeプロジェクトに移行後、
///       実際のFirebase Storage SDKに置き換えてください。
@MainActor
@Observable
final class StorageService {
    /// シングルトンインスタンス
    static let shared = StorageService()

    /// アップロード中かどうか
    var isUploading = false

    /// エラーメッセージ
    var errorMessage: String?

    private init() {}

    /// 画像をアップロード
    /// - Parameters:
    ///   - imageData: 画像データ
    ///   - path: 保存先パス（例: "buildings/building_id/image_001.jpg"）
    /// - Returns: アップロードされた画像のURL
    func uploadImage(imageData: Data, path: String) async throws -> String {
        isUploading = true
        errorMessage = nil

        defer { isUploading = false }

        // 実際の実装:
        // let storageRef = Storage.storage().reference().child(path)
        // let metadata = StorageMetadata()
        // metadata.contentType = "image/jpeg"
        // _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        // let downloadURL = try await storageRef.downloadURL()
        // return downloadURL.absoluteString

        // モック実装: シミュレート遅延
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // モックURL生成
        let mockUrl = "https://storage.example.com/\(path)"
        return mockUrl
    }

    /// 複数画像をアップロード
    /// - Parameters:
    ///   - images: 画像データの配列
    ///   - basePath: ベースパス（例: "buildings/building_id"）
    /// - Returns: アップロードされた画像のURL配列
    func uploadImages(images: [Data], basePath: String) async throws -> [String] {
        var urls: [String] = []

        for (index, imageData) in images.enumerated() {
            let path = "\(basePath)/image_\(String(format: "%03d", index)).jpg"
            let url = try await uploadImage(imageData: imageData, path: path)
            urls.append(url)
        }

        return urls
    }

    /// 画像を削除
    /// - Parameter path: 削除するファイルのパス
    func deleteImage(path: String) async throws {
        // 実際の実装:
        // let storageRef = Storage.storage().reference().child(path)
        // try await storageRef.delete()

        // モック実装
        try await Task.sleep(nanoseconds: 300_000_000)
    }

    /// URLから画像パスを抽出
    /// - Parameter url: 画像URL
    /// - Returns: Storage内のパス
    func extractPath(from url: String) -> String? {
        // URLからパスを抽出するロジック
        // 実際の実装ではFirebase StorageのURL形式に合わせる
        guard let urlComponents = URLComponents(string: url),
              let path = urlComponents.path.split(separator: "/").last else {
            return nil
        }
        return String(path)
    }

    /// UIImageをJPEGデータに変換
    /// - Parameters:
    ///   - image: 変換する画像
    ///   - compressionQuality: 圧縮品質（0.0〜1.0）
    /// - Returns: JPEGデータ
    func convertToJPEG(image: UIImage, compressionQuality: CGFloat = 0.8) -> Data? {
        return image.jpegData(compressionQuality: compressionQuality)
    }

    /// 画像をリサイズ
    /// - Parameters:
    ///   - image: リサイズする画像
    ///   - maxDimension: 最大サイズ（幅または高さ）
    /// - Returns: リサイズされた画像
    func resizeImage(_ image: UIImage, maxDimension: CGFloat = 1200) -> UIImage {
        let size = image.size

        // すでに小さい場合はそのまま返す
        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }

        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
