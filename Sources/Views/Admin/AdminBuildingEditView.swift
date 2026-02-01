import SwiftUI
import PhotosUI

/// 管理者用ビル編集画面
struct AdminBuildingEditView: View {
    /// ViewModel
    @State private var viewModel: AdminBuildingEditViewModel

    /// 環境からのdismiss
    @Environment(\.dismiss) private var dismiss

    /// 保存完了時のコールバック
    var onSave: (() -> Void)?

    init(building: Building?, onSave: (() -> Void)? = nil) {
        _viewModel = State(initialValue: AdminBuildingEditViewModel(building: building))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                // 基本情報セクション
                Section("基本情報") {
                    TextField("ビル名（必須）", text: $viewModel.name)

                    TextField("郵便番号", text: $viewModel.postalCode)
                        .keyboardType(.numberPad)

                    TextField("住所", text: $viewModel.address)
                }

                // 位置情報セクション
                Section {
                    TextField("緯度（必須）", text: $viewModel.latitudeString)
                        .keyboardType(.decimalPad)

                    TextField("経度（必須）", text: $viewModel.longitudeString)
                        .keyboardType(.decimalPad)
                } header: {
                    Text("位置情報")
                } footer: {
                    Text("例: 緯度 35.6812, 経度 139.7671")
                }

                // 建物情報セクション
                Section("建物情報") {
                    TextField("高さ（m）", text: $viewModel.heightString)
                        .keyboardType(.decimalPad)

                    TextField("地上階数", text: $viewModel.floorsAboveString)
                        .keyboardType(.numberPad)

                    TextField("地下階数", text: $viewModel.floorsBelowString)
                        .keyboardType(.numberPad)

                    TextField("設計", text: $viewModel.architect)

                    TextField("施工", text: $viewModel.constructor)
                }

                // 画像セクション
                Section {
                    // 既存画像
                    if !viewModel.existingImageUrls.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.existingImageUrls, id: \.self) { url in
                                    ZStack(alignment: .topTrailing) {
                                        AsyncImage(url: URL(string: url)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                        }
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                        Button {
                                            viewModel.markImageForDeletion(url)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .red)
                                        }
                                        .offset(x: 4, y: -4)
                                    }
                                }
                            }
                        }
                    }

                    // 新規追加画像
                    if !viewModel.newImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.newImages.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: viewModel.newImages[index])
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))

                                        Button {
                                            viewModel.removeNewImage(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .red)
                                        }
                                        .offset(x: 4, y: -4)
                                    }
                                }
                            }
                        }
                    }

                    // 画像追加ボタン
                    PhotosPicker(
                        selection: $viewModel.selectedPhotoItems,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Label("画像を追加", systemImage: "photo.badge.plus")
                    }
                    .onChange(of: viewModel.selectedPhotoItems) { _, newItems in
                        Task {
                            await viewModel.loadImages(from: newItems)
                        }
                    }
                } header: {
                    Text("フォトギャラリー")
                } footer: {
                    Text("最大10枚まで追加できます")
                }
            }
            .navigationTitle(viewModel.isNewBuilding ? "ビルを追加" : "ビルを編集")
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
    AdminBuildingEditView(building: nil)
}

#Preview("編集") {
    AdminBuildingEditView(building: Building.mockData[0])
}
