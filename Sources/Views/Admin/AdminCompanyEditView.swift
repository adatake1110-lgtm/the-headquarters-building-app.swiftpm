import SwiftUI

/// 管理者用企業編集画面
struct AdminCompanyEditView: View {
    /// ViewModel
    @State private var viewModel: AdminCompanyEditViewModel

    /// 環境からのdismiss
    @Environment(\.dismiss) private var dismiss

    /// 保存完了時のコールバック
    var onSave: (() -> Void)?

    init(company: Company?, onSave: (() -> Void)? = nil) {
        _viewModel = State(initialValue: AdminCompanyEditViewModel(company: company))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                // 基本情報セクション
                Section("基本情報") {
                    TextField("企業名（必須）", text: $viewModel.name)

                    Picker("業界（必須）", selection: $viewModel.industry) {
                        Text("選択してください").tag("")
                        ForEach(viewModel.industryOptions, id: \.self) { industry in
                            Text(industry).tag(industry)
                        }
                    }
                }

                // 企業概要セクション
                Section("企業概要") {
                    TextField("企業概要を入力", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                }

                // 本社ビルセクション
                Section {
                    Picker("本社ビル（必須）", selection: $viewModel.selectedBuildingId) {
                        Text("選択してください").tag(nil as String?)
                        ForEach(viewModel.availableBuildings) { building in
                            Text(building.name).tag(building.buildingId as String?)
                        }
                    }
                    .onChange(of: viewModel.selectedBuildingId) { _, _ in
                        viewModel.onBuildingSelected()
                    }

                    if let building = viewModel.selectedBuilding {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(building.address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if let floors = building.floorDescription {
                                Text(floors)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("本社ビル")
                } footer: {
                    Text("ビルを選択すると住所情報が自動入力されます")
                }

                // 住所情報セクション
                Section("住所情報") {
                    TextField("郵便番号", text: $viewModel.postalCode)
                        .keyboardType(.numberPad)

                    TextField("住所", text: $viewModel.address)
                }

                // 位置情報セクション
                Section {
                    TextField("緯度", text: $viewModel.latitudeString)
                        .keyboardType(.decimalPad)

                    TextField("経度", text: $viewModel.longitudeString)
                        .keyboardType(.decimalPad)

                    TextField("地図埋め込みHTML", text: $viewModel.mapEmbed, axis: .vertical)
                        .lineLimit(2...4)
                        .font(.caption)

                    if !viewModel.mapEmbed.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button("埋め込みHTMLから座標を抽出") {
                            viewModel.extractCoordinatesFromMapEmbed()
                        }
                    }
                } header: {
                    Text("位置情報")
                } footer: {
                    Text("緯度・経度を直接入力するか、Google Maps埋め込みHTMLを貼り付けて座標を抽出できます")
                }

                // ストリートビューセクション
                Section {
                    TextField("ストリートビュー埋め込みHTML", text: $viewModel.streetviewEmbed, axis: .vertical)
                        .lineLimit(2...4)
                        .font(.caption)
                } header: {
                    Text("ストリートビュー")
                } footer: {
                    Text("Google Mapsストリートビューの埋め込みiframeタグを貼り付け")
                }
            }
            .navigationTitle(viewModel.isNewCompany ? "企業を追加" : "企業を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            if await viewModel.save() {
                                onSave?()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isValidInput || viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView("保存中...")
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .alert("エラー", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}

#Preview("新規作成") {
    AdminCompanyEditView(company: nil)
}

#Preview("編集") {
    AdminCompanyEditView(company: Company.mockData[0])
}
