import SwiftUI

/// お気に入りボタン
struct FavoriteButton: View {
    /// お気に入り状態
    let isFavorite: Bool

    /// タップ時のアクション
    let action: () -> Void

    /// アニメーション用スケール
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            // タップアニメーション
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.0
                }
            }
            action()
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isFavorite ? .red : .gray)
                .scaleEffect(scale)
        }
        .accessibilityLabel(isFavorite ? "お気に入りを解除" : "お気に入りに追加")
    }
}

#Preview {
    HStack(spacing: 40) {
        FavoriteButton(isFavorite: false, action: {})
        FavoriteButton(isFavorite: true, action: {})
    }
    .padding()
}
