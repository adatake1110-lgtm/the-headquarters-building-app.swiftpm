import Foundation

/// CSVインポートエラー
enum CSVImportError: LocalizedError {
    case fileNotFound(String)
    case invalidFormat(String)
    case parsingError(String, Int)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "ファイルが見つかりません: \(filename)"
        case .invalidFormat(let message):
            return "フォーマットエラー: \(message)"
        case .parsingError(let message, let line):
            return "パースエラー（行 \(line)）: \(message)"
        }
    }
}

/// CSVインポーター
/// ビル・企業データをCSVファイルから読み込む
struct CSVImporter {

    // MARK: - Buildings

    /// ビルCSVを読み込み
    /// - Parameter filename: CSVファイル名（拡張子なし）
    /// - Returns: Buildingの配列
    static func importBuildings(from filename: String = "buildings") throws -> [Building] {
        let csvString = try loadCSVString(filename: filename)
        return try parseBuildings(from: csvString)
    }

    /// ビルCSV文字列をパース
    static func parseBuildings(from csvString: String) throws -> [Building] {
        let rows = parseCSVRows(csvString)

        guard rows.count > 1 else {
            throw CSVImportError.invalidFormat("ヘッダー行とデータ行が必要です")
        }

        // ヘッダー行を取得
        let headers = rows[0].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }

        // 必須カラムのインデックスを取得
        guard let nameIndex = headers.firstIndex(of: "name"),
              let addressIndex = headers.firstIndex(of: "address") else {
            throw CSVImportError.invalidFormat("必須カラム（name, address）がありません")
        }

        // 座標カラム（latitude/longitudeまたはmap_embedが必要）
        let latitudeIndex = headers.firstIndex(of: "latitude")
        let longitudeIndex = headers.firstIndex(of: "longitude")
        let mapEmbedIndex = headers.firstIndex(of: "map_embed")

        // オプションカラムのインデックス
        let idIndex = headers.firstIndex(of: "building_id")
        let postalCodeIndex = headers.firstIndex(of: "postal_code")
        let heightIndex = headers.firstIndex(of: "height")
        let floorsAboveIndex = headers.firstIndex(of: "floors_above")
        let floorsBelowIndex = headers.firstIndex(of: "floors_below")
        let architectIndex = headers.firstIndex(of: "architect")
        let constructorIndex = headers.firstIndex(of: "constructor")
        let imageUrlsIndex = headers.firstIndex(of: "image_urls")
        let streetviewEmbedIndex = headers.firstIndex(of: "streetview_embed")

        var buildings: [Building] = []

        // データ行をパース
        for (index, row) in rows.dropFirst().enumerated() {
            let lineNumber = index + 2 // ヘッダー行 + 0-indexed

            guard row.count > max(nameIndex, addressIndex) else {
                continue // 空行をスキップ
            }

            let name = row[nameIndex].trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { continue }

            // 座標を取得（latitude/longitude または map_embed から抽出）
            var latitude: Double?
            var longitude: Double?

            // 1. まずlatitude/longitudeカラムから取得を試みる
            if let latIdx = latitudeIndex, let lngIdx = longitudeIndex,
               row.indices.contains(latIdx), row.indices.contains(lngIdx) {
                latitude = Double(row[latIdx].trimmingCharacters(in: .whitespaces))
                longitude = Double(row[lngIdx].trimmingCharacters(in: .whitespaces))
            }

            // 2. 座標が取得できない場合、map_embedから抽出
            if latitude == nil || longitude == nil,
               let embedIdx = mapEmbedIndex,
               row.indices.contains(embedIdx) {
                let embedHTML = row[embedIdx].trimmingCharacters(in: .whitespaces)
                if !embedHTML.isEmpty,
                   let coords = GoogleMapsEmbedParser.extractCoordinates(from: embedHTML) {
                    latitude = coords.latitude
                    longitude = coords.longitude
                }
            }

            // 座標が取得できない場合はエラー
            guard let finalLatitude = latitude, let finalLongitude = longitude else {
                throw CSVImportError.parsingError("緯度・経度が不正です（latitude/longitudeまたはmap_embedを指定してください）", lineNumber)
            }

            let building = Building(
                buildingId: idIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .trimmingCharacters(in: .whitespaces).nilIfEmpty ?? UUID().uuidString,
                name: name,
                postalCode: postalCodeIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .trimmingCharacters(in: .whitespaces) ?? "",
                address: row[addressIndex].trimmingCharacters(in: .whitespaces),
                latitude: finalLatitude,
                longitude: finalLongitude,
                height: heightIndex.flatMap { row.indices.contains($0) ? Double(row[$0].trimmingCharacters(in: .whitespaces)) : nil },
                floorsAbove: floorsAboveIndex.flatMap { row.indices.contains($0) ? Int(row[$0].trimmingCharacters(in: .whitespaces)) : nil },
                floorsBelow: floorsBelowIndex.flatMap { row.indices.contains($0) ? Int(row[$0].trimmingCharacters(in: .whitespaces)) : nil },
                architect: architectIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .trimmingCharacters(in: .whitespaces).nilIfEmpty,
                constructor: constructorIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .trimmingCharacters(in: .whitespaces).nilIfEmpty,
                imageUrls: imageUrlsIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .split(separator: "|").map { String($0).trimmingCharacters(in: .whitespaces) } ?? [],
                streetviewEmbed: streetviewEmbedIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .trimmingCharacters(in: .whitespaces).nilIfEmpty,
                createdAt: Date(),
                updatedAt: Date()
            )

            buildings.append(building)
        }

        return buildings
    }

    // MARK: - Companies

    /// 企業CSVを読み込み
    /// - Parameter filename: CSVファイル名（拡張子なし）
    /// - Returns: Companyの配列
    static func importCompanies(from filename: String = "companies") throws -> [Company] {
        let csvString = try loadCSVString(filename: filename)
        return try parseCompanies(from: csvString)
    }

    /// 企業CSV文字列をパース
    static func parseCompanies(from csvString: String) throws -> [Company] {
        let rows = parseCSVRows(csvString)

        guard rows.count > 1 else {
            throw CSVImportError.invalidFormat("ヘッダー行とデータ行が必要です")
        }

        // ヘッダー行を取得
        let headers = rows[0].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }

        // 必須カラムのインデックスを取得
        guard let nameIndex = headers.firstIndex(of: "name"),
              let industryIndex = headers.firstIndex(of: "industry"),
              let buildingIdIndex = headers.firstIndex(of: "building_id") else {
            throw CSVImportError.invalidFormat("必須カラム（name, industry, building_id）がありません")
        }

        // オプションカラムのインデックス
        let idIndex = headers.firstIndex(of: "company_id")
        let descriptionIndex = headers.firstIndex(of: "description")
        let postalCodeIndex = headers.firstIndex(of: "postal_code")
        let addressIndex = headers.firstIndex(of: "address")
        let latitudeIndex = headers.firstIndex(of: "latitude")
        let longitudeIndex = headers.firstIndex(of: "longitude")
        let mapEmbedIndex = headers.firstIndex(of: "map_embed")
        let streetviewEmbedIndex = headers.firstIndex(of: "streetview_embed")

        var companies: [Company] = []

        // データ行をパース
        for (index, row) in rows.dropFirst().enumerated() {
            let lineNumber = index + 2

            guard row.count > max(nameIndex, industryIndex, buildingIdIndex) else {
                continue
            }

            let name = row[nameIndex].trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { continue }

            let buildingId = row[buildingIdIndex].trimmingCharacters(in: .whitespaces)
            guard !buildingId.isEmpty else {
                throw CSVImportError.parsingError("building_idが空です", lineNumber)
            }

            // 座標を取得（latitude/longitude または map_embed から抽出）
            var companyLatitude: Double = 0
            var companyLongitude: Double = 0

            // 1. まずlatitude/longitudeカラムから取得を試みる
            if let latIdx = latitudeIndex, let lngIdx = longitudeIndex,
               row.indices.contains(latIdx), row.indices.contains(lngIdx) {
                companyLatitude = Double(row[latIdx].trimmingCharacters(in: .whitespaces)) ?? 0
                companyLongitude = Double(row[lngIdx].trimmingCharacters(in: .whitespaces)) ?? 0
            }

            // 2. 座標が0の場合、map_embedから抽出を試みる
            if companyLatitude == 0 && companyLongitude == 0,
               let embedIdx = mapEmbedIndex,
               row.indices.contains(embedIdx) {
                let embedHTML = row[embedIdx].trimmingCharacters(in: .whitespaces)
                if !embedHTML.isEmpty,
                   let coords = GoogleMapsEmbedParser.extractCoordinates(from: embedHTML) {
                    companyLatitude = coords.latitude
                    companyLongitude = coords.longitude
                }
            }

            let company = Company(
                companyId: idIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .trimmingCharacters(in: .whitespaces).nilIfEmpty ?? UUID().uuidString,
                name: name,
                industry: row[industryIndex].trimmingCharacters(in: .whitespaces),
                description: descriptionIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .trimmingCharacters(in: .whitespaces) ?? "",
                buildingId: buildingId,
                postalCode: postalCodeIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .trimmingCharacters(in: .whitespaces) ?? "",
                address: addressIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .trimmingCharacters(in: .whitespaces) ?? "",
                latitude: companyLatitude,
                longitude: companyLongitude,
                streetviewEmbed: streetviewEmbedIndex.flatMap { row.indices.contains($0) ? row[$0] : nil }?
                    .trimmingCharacters(in: .whitespaces).nilIfEmpty,
                createdAt: Date(),
                updatedAt: Date()
            )

            companies.append(company)
        }

        return companies
    }

    // MARK: - Private Helpers

    /// CSVファイルを読み込み
    private static func loadCSVString(filename: String) throws -> String {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "csv") else {
            throw CSVImportError.fileNotFound("\(filename).csv")
        }

        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw CSVImportError.fileNotFound("\(filename).csv - \(error.localizedDescription)")
        }
    }

    /// CSV文字列を行と列に分割
    private static func parseCSVRows(_ csvString: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in csvString {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                currentRow.append(currentField)
                currentField = ""
            } else if (char == "\n" || char == "\r") && !insideQuotes {
                if !currentField.isEmpty || !currentRow.isEmpty {
                    currentRow.append(currentField)
                    if !currentRow.allSatisfy({ $0.isEmpty }) {
                        rows.append(currentRow)
                    }
                    currentRow = []
                    currentField = ""
                }
            } else {
                currentField.append(char)
            }
        }

        // 最後のフィールドと行を追加
        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField)
            if !currentRow.allSatisfy({ $0.isEmpty }) {
                rows.append(currentRow)
            }
        }

        return rows
    }
}

// MARK: - String Extension

private extension String {
    /// 空文字列の場合nilを返す
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
