import SwiftUI

/// ビル概要カード
/// マップ上でビルのピンをタップした際に表示
struct BuildingCardView: View {
    /// 表示するビル
    let building: Building

    /// 入居企業一覧
    let tenantCompanies: [Company]

    /// 詳細ボタンタップ時のアクション
    let onDetailTap: () -> Void

    /// 閉じるボタンタップ時のアクション
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(building.name)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(building.address)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }

            // 入居企業
            if !tenantCompanies.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("主な入居企業")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)

                    ForEach(tenantCompanies.prefix(3)) { company in
                        HStack(spacing: 6) {
                            Image(systemName: "building.2")
                                .font(.caption)
                                .foregroundStyle(AppColors.primary)
                            Text(company.name)
                                .font(.subheadline)
                        }
                    }

                    if tenantCompanies.count > 3 {
                        Text("他 \(tenantCompanies.count - 3) 社")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }

            // 詳細ボタン
            Button(action: onDetailTap) {
                HStack {
                    Text("詳細を見る")
                        .fontWeight(.medium)
                    Image(systemName: "chevron.right")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    BuildingCardView(
        building: Building.mockData[0],
        tenantCompanies: Array(Company.mockData.prefix(2)),
        onDetailTap: {},
        onDismiss: {}
    )
    .padding()
}
