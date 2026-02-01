import SwiftUI
@preconcurrency import MapKit

/// ストリートビュー（Look Around）表示ボタン
struct StreetViewButton: View {
    /// 緯度
    let latitude: Double

    /// 経度
    let longitude: Double

    /// Look Aroundシーン
    @State private var lookAroundScene: MKLookAroundScene?

    /// Look Around表示中かどうか
    @State private var isShowingLookAround = false

    /// 読み込み中かどうか
    @State private var isLoading = false

    /// 利用不可メッセージ表示
    @State private var showUnavailableAlert = false

    var body: some View {
        Button {
            Task {
                await fetchLookAroundScene()
            }
        } label: {
            HStack {
                Image(systemName: "binoculars.fill")
                Text("ストリートビュー")
                Spacer()
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .disabled(isLoading)
        .lookAroundViewer(isPresented: $isShowingLookAround, scene: $lookAroundScene)
        .alert("ストリートビュー", isPresented: $showUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("この場所ではストリートビューを利用できません。")
        }
    }

    /// Look Aroundシーンを取得
    private func fetchLookAroundScene() async {
        isLoading = true

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let request = MKLookAroundSceneRequest(coordinate: coordinate)

        do {
            let scene = try await request.scene
            await MainActor.run {
                if let scene = scene {
                    lookAroundScene = scene
                    isShowingLookAround = true
                } else {
                    showUnavailableAlert = true
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                showUnavailableAlert = true
                isLoading = false
            }
        }
    }
}

#Preview {
    List {
        StreetViewButton(
            latitude: 35.6604,
            longitude: 139.7292
        )
    }
}
