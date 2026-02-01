import SwiftUI

/// 設定画面
struct SettingsView: View {
    /// ViewModel
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        List {
            // 有料版セクション
            Section {
                if viewModel.isPremium {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("有料版（購入済み）")
                        Spacer()
                    }
                } else {
                    Button {
                        Task {
                            await viewModel.purchasePremium()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("有料版を購入（¥\(Constants.premiumPrice)）")
                            Spacer()
                            if viewModel.isPurchasing {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(viewModel.isPurchasing)

                    Button("購入を復元") {
                        Task {
                            await viewModel.restorePurchases()
                        }
                    }
                    .disabled(viewModel.isPurchasing)
                }
            } header: {
                Text("有料版")
            } footer: {
                if !viewModel.isPremium {
                    Text("有料版では広告非表示、お気に入り無制限になります。")
                }
            }

            // お気に入りセクション
            Section("お気に入り") {
                NavigationLink {
                    FavoriteListView()
                } label: {
                    HStack {
                        Text("お気に入り一覧")
                        Spacer()
                        if !viewModel.isPremium {
                            Text("\(viewModel.totalFavoriteCount)/\(viewModel.favoriteLimit)")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(viewModel.totalFavoriteCount)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // 表示設定セクション
            Section("表示設定") {
                Picker("ダークモード", selection: $viewModel.colorSchemeSelection) {
                    Text("システム連動").tag(0)
                    Text("ライト").tag(1)
                    Text("ダーク").tag(2)
                }

                NavigationLink("地図初期表示エリア") {
                    MapAreaSettingView()
                }
            }

            // サポートセクション
            Section("サポート") {
                Link(destination: URL(string: "mailto:support@example.com")!) {
                    HStack {
                        Text("お問い合わせ")
                        Spacer()
                        Image(systemName: "envelope")
                            .foregroundStyle(.secondary)
                    }
                }

                Link(destination: URL(string: "https://example.com/terms")!) {
                    HStack {
                        Text("利用規約")
                        Spacer()
                        Image(systemName: "doc.text")
                            .foregroundStyle(.secondary)
                    }
                }

                Link(destination: URL(string: "https://example.com/privacy")!) {
                    HStack {
                        Text("プライバシーポリシー")
                        Spacer()
                        Image(systemName: "hand.raised")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // アプリ情報セクション
            Section("アプリ情報") {
                HStack {
                    Text("バージョン")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("設定")
    }
}

/// お気に入り一覧画面
struct FavoriteListView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        List {
            if !viewModel.favoriteBuildings.isEmpty {
                Section("ビル") {
                    ForEach(viewModel.favoriteBuildings) { building in
                        NavigationLink(value: building) {
                            BuildingRowView(building: building)
                        }
                    }
                }
            }

            if !viewModel.favoriteCompanies.isEmpty {
                Section("企業") {
                    ForEach(viewModel.favoriteCompanies) { company in
                        NavigationLink(value: company) {
                            CompanyRowView(company: company)
                        }
                    }
                }
            }
        }
        .navigationTitle("お気に入り")
        .navigationDestination(for: Building.self) { building in
            BuildingDetailView(building: building)
        }
        .navigationDestination(for: Company.self) { company in
            CompanyDetailView(company: company)
        }
        .overlay {
            if viewModel.favoriteBuildings.isEmpty && viewModel.favoriteCompanies.isEmpty {
                ContentUnavailableView(
                    "お気に入りがありません",
                    systemImage: "heart",
                    description: Text("ビルや企業の詳細画面からお気に入り登録できます")
                )
            }
        }
    }
}

/// 地図初期表示エリア設定画面
struct MapAreaSettingView: View {
    @State private var appState = AppState.shared

    let areas: [(name: String, latitude: Double, longitude: Double)] = [
        ("東京（丸の内）", 35.6812, 139.7671),
        ("東京（渋谷）", 35.6580, 139.7016),
        ("東京（六本木）", 35.6604, 139.7292),
        ("大阪（梅田）", 34.7024, 135.4959),
        ("名古屋（栄）", 35.1709, 136.9066),
        ("福岡（天神）", 33.5902, 130.3986)
    ]

    var body: some View {
        List {
            ForEach(areas, id: \.name) { area in
                Button {
                    appState.defaultMapLatitude = area.latitude
                    appState.defaultMapLongitude = area.longitude
                } label: {
                    HStack {
                        Text(area.name)
                        Spacer()
                        if appState.defaultMapLatitude == area.latitude &&
                           appState.defaultMapLongitude == area.longitude {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AppColors.primary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("地図初期表示エリア")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppState.shared)
}
