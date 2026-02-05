import SwiftUI
import MapKit

/// 企業詳細画面
struct CompanyDetailView: View {
    /// 企業
    let company: Company

    /// ViewModel
    @State private var viewModel: CompanyDetailViewModel

    init(company: Company) {
        self.company = company
        _viewModel = State(initialValue: CompanyDetailViewModel(company: company))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 地図
                Map(initialPosition: .region(viewModel.mapRegion)) {
                    Marker(company.name, coordinate: CLLocationCoordinate2D(
                        latitude: company.latitude,
                        longitude: company.longitude
                    ))
                    .tint(AppColors.primary)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // ストリートビュー
                if let embedHTML = company.streetviewEmbed {
                    EmbeddedStreetViewSection(embedHTML: embedHTML)
                } else {
                    SectionView(title: "ストリートビュー") {
                        StreetViewButton(
                            latitude: company.latitude,
                            longitude: company.longitude
                        )
                    }
                }

                // 基本情報セクション
                SectionView(title: "基本情報") {
                    InfoRow(label: "業界", value: company.industry)
                    InfoRow(label: "郵便番号", value: "〒\(company.postalCode)")
                    InfoRow(label: "住所", value: company.address)
                }

                // 企業概要セクション
                SectionView(title: "企業概要") {
                    Text(company.description)
                        .font(.subheadline)
                        .lineSpacing(4)
                }

                // 本社ビルセクション
                if let building = viewModel.headquartersBuilding {
                    SectionView(title: "本社ビル") {
                        NavigationLink(value: building) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(building.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    if let floors = building.floorDescription {
                                        Text(floors)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(company.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Building.self) { building in
            BuildingDetailView(building: building)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(
                    isFavorite: viewModel.isFavorite,
                    action: {
                        viewModel.toggleFavorite()
                    }
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            AdBannerView()
        }
    }
}

#Preview {
    NavigationStack {
        CompanyDetailView(company: Company.mockData[0])
    }
}
