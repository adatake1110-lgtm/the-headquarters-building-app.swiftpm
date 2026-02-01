import SwiftUI

/// 管理者ログイン画面
struct AdminLoginView: View {
    /// ViewModel
    @State private var viewModel = AdminAuthViewModel()

    /// 環境からのdismiss
    @Environment(\.dismiss) private var dismiss

    /// ログイン成功時のコールバック
    var onLoginSuccess: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                // ログイン情報セクション
                Section {
                    TextField("メールアドレス", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    SecureField("パスワード", text: $viewModel.password)
                        .textContentType(.password)
                } header: {
                    Text("管理者アカウント")
                } footer: {
                    Text("管理者のみログイン可能です")
                }

                // エラーメッセージ
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.subheadline)
                    }
                }

                // ログインボタン
                Section {
                    Button {
                        Task {
                            if await viewModel.login() {
                                onLoginSuccess?()
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("ログイン")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isValidInput || viewModel.isLoading)
                }
            }
            .navigationTitle("管理者ログイン")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AdminLoginView()
}
