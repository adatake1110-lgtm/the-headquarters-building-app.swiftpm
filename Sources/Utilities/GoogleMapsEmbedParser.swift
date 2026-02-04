import Foundation

/// Google Maps埋め込みURLから座標を抽出するユーティリティ
enum GoogleMapsEmbedParser {

    /// 座標情報
    struct Coordinates {
        let latitude: Double
        let longitude: Double
    }

    /// 埋め込みHTMLまたはURLから座標を抽出
    /// - Parameter embedHTML: iframeタグまたはURL文字列
    /// - Returns: 抽出された座標（抽出失敗時はnil）
    static func extractCoordinates(from embedHTML: String) -> Coordinates? {
        // iframeからsrc属性を抽出
        let urlString: String
        if embedHTML.contains("<iframe") {
            guard let srcURL = extractSrcFromIframe(embedHTML) else {
                return nil
            }
            urlString = srcURL
        } else {
            urlString = embedHTML
        }

        // URLからpbパラメータを取得
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let pbValue = components.queryItems?.first(where: { $0.name == "pb" })?.value else {
            return nil
        }

        // pbパラメータから座標を抽出
        // 形式: !2d{経度}!3d{緯度}
        return extractCoordinatesFromPb(pbValue)
    }

    /// iframeタグからsrc属性を抽出
    private static func extractSrcFromIframe(_ html: String) -> String? {
        // src="..." または src='...' を抽出
        let patterns = [
            #"src\s*=\s*"([^"]+)""#,
            #"src\s*=\s*'([^']+)'"#
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)),
               let range = Range(match.range(at: 1), in: html) {
                return String(html[range])
            }
        }

        return nil
    }

    /// pbパラメータから座標を抽出
    /// pbパラメータは!区切りで、2d=経度、3d=緯度
    private static func extractCoordinatesFromPb(_ pb: String) -> Coordinates? {
        var latitude: Double?
        var longitude: Double?

        // !で分割して各パラメータを解析
        let components = pb.components(separatedBy: "!")

        for component in components {
            // 2d = 経度 (longitude)
            if component.hasPrefix("2d") {
                let value = String(component.dropFirst(2))
                longitude = Double(value)
            }
            // 3d = 緯度 (latitude)
            else if component.hasPrefix("3d") {
                let value = String(component.dropFirst(2))
                latitude = Double(value)
            }
        }

        // 両方の値が取得できた場合のみ返す
        if let lat = latitude, let lng = longitude {
            // 緯度は-90〜90、経度は-180〜180の範囲チェック
            if lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180 {
                return Coordinates(latitude: lat, longitude: lng)
            }
        }

        return nil
    }
}
