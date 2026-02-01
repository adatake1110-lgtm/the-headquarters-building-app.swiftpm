import SwiftUI

/// 管理者ダッシュボード
struct AdminDashboardView: View {
    /// ViewModel
    @State private var viewModel = AdminAuthViewModel()

    /// 環境からのdismiss
    @Environment(\.dismiss) private var dismiss

    /// ログアウト確認アラート
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                // 管理者情報セクション
                Section {
                    if let admin = viewModel.currentAdmin {
                        HStack {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .font(.title2)
                                .foregroundStyle(AppColors.primary)

                            VStack(alignment: .leading) {
                                Text(admin.displayName ?? "管理者")
                                    .font(.headline)
                                Text(admin.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("ログイン中")
                }

                // 管理メニューセクション
                Section("データ管理") {
                    NavigationLink {
                        AdminBuildingListView()
                    } label: {
                        Label {
                            VStack(alignment: .leading) {
                                Text("ビル管理")
                                Text("ビルの追加・編集・削除")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "building.2.fill")
                                .foregroundStyle(AppColors.primary)
                        }
                    }

                    NavigationLink {
                        AdminCompanyListView()
                    } label: {
                        Label {
                            VStack(alignment: .leading) {
                                Text("企業管理")
                                Text("企業の追加・編集・削除")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "briefcase.fill")
                                .foregroundStyle(AppColors.primary)
                        }
                    }
                }

                // ログアウトセクション
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirmation = true
                    } label: {
                        Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("管理者ダッシュボード")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .alert("ログアウト", isPresented: $showLogoutConfirmation) {
                Button("キャンセル", role: .cancel) {}
                Button("ログアウト", role: .destructive) {
                    Task {
                        await viewModel.logout()
                        dismiss()
                    }
                }
            } message: {
                Text("管理者からログアウトしますか？")
            }
        }
    }
}

#Preview {
    AdminDashboardView()
}
