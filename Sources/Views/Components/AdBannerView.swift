import SwiftUI

/// 広告バナービュー
/// Google AdMob統合時に実装を置き換え
/// 現在はプレースホルダー表示
struct AdBannerView: View {
    var body: some View {
        // TODO: Google AdMob SDKを統合後、実際の広告に置き換え
        // 現在はプレースホルダー表示
        HStack {
            Spacer()
            Text("広告スペース")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(height: 50)
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    VStack {
        Spacer()
        AdBannerView()
    }
}
