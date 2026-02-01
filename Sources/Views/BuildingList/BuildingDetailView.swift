import SwiftUI
import MapKit

/// ビル詳細画面
struct BuildingDetailView: View {
    /// ビル
    let building: Building

    /// ViewModel
    @State private var viewModel: BuildingDetailViewModel

    /// アプリ状態
    @Environment(AppState.self) private var appState

    /// お気に入り追加失敗アラート
    @State private var showFavoriteLimitAlert = false

    init(building: Building) {
        self.building = building
        _viewModel = State(initialValue: BuildingDetailViewModel(building: building))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 地図
                Map(initialPosition: .region(viewModel.mapRegion)) {
                    Marker(building.name, coordinate: CLLocationCoordinate2D(
                        latitude: building.latitude,
                        longitude: building.longitude
                    ))
                    .tint(AppColors.primary)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // ストリートビュー
                SectionView(title: "ストリートビュー") {
                    StreetViewButton(
                        latitude: building.latitude,
                        longitude: building.longitude
                    )
                }

                // 基本情報セクション
                SectionView(title: "基本情報") {
                    InfoRow(label: "郵便番号", value: "〒\(building.postalCode)")
                    InfoRow(label: "住所", value: building.address)
                    if let height = building.heightDescription {
                        InfoRow(label: "高さ", value: height)
                    }
                    if let floors = building.floorDescription {
                        InfoRow(label: "階数", value: floors)
                    }
                }

                // 設計・施工セクション
                if building.architect != nil || building.constructor != nil {
                    SectionView(title: "設計・施工") {
                        if let architect = building.architect {
                            InfoRow(label: "設計", value: architect)
                        }
                        if let constructor = building.constructor {
                            InfoRow(label: "施工", value: constructor)
                        }
                    }
                }

                // 入居企業セクション
                if !viewModel.tenantCompanies.isEmpty {
                    SectionView(title: "主な入居企業") {
                        ForEach(viewModel.tenantCompanies) { company in
                            NavigationLink(value: company) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(company.name)
                                            .font(.subheadline)
                                        Text(company.industry)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // フォトギャラリー（画像がある場合）
                if !building.imageUrls.isEmpty {
                    SectionView(title: "フォトギャラリー") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(building.imageUrls, id: \.self) { imageUrl in
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                    }
                                    .frame(width: 200, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(building.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Company.self) { company in
            CompanyDetailView(company: company)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(
                    isFavorite: viewModel.isFavorite,
                    action: {
                        if !viewModel.toggleFavorite() {
                            showFavoriteLimitAlert = true
                        }
                    }
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !appState.isPremium {
                AdBannerView()
            }
        }
        .alert("お気に入り上限", isPresented: $showFavoriteLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("無料版ではお気に入りは\(Constants.freeVersionFavoriteLimit)件までです。有料版にアップグレードすると無制限になります。")
        }
    }
}

/// セクションビュー
struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppColors.primary)

            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

/// 情報行ビュー
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)

            Text(value)
                .font(.subheadline)
        }
    }
}

#Preview {
    NavigationStack {
        BuildingDetailView(building: Building.mockData[0])
    }
    .environment(AppState.shared)
}
