import SwiftUI
import WebKit

/// Google Maps埋め込み用WebView
struct StreetViewWebView: UIViewRepresentable {
    /// 埋め込みHTML（iframeタグ）
    let embedHTML: String

    /// 高さ
    let height: CGFloat

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // iframeを含むHTMLを生成
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                html, body { width: 100%; height: 100%; overflow: hidden; }
                iframe { width: 100%; height: 100%; border: 0; border-radius: 12px; }
            </style>
        </head>
        <body>
            \(embedHTML)
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
    }
}

/// ストリートビュー埋め込みセクション
struct EmbeddedStreetViewSection: View {
    /// 埋め込みHTML
    let embedHTML: String

    /// 高さ
    var height: CGFloat = 250

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ストリートビュー")
                .font(.headline)
                .foregroundStyle(AppColors.primary)

            StreetViewWebView(embedHTML: embedHTML, height: height)
                .frame(height: height)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    EmbeddedStreetViewSection(
        embedHTML: """
        <iframe src="https://www.google.com/maps/embed?pb=!4v1720966466519!6m8!1m7!1sK8hyUuOQQ68tDULHvedTaQ!2m2!1d35.66064713530854!2d139.730838387311!3f256.7598663626702!4f37.016209895102534!5f0.7820865974627469" width="600" height="450" allowfullscreen="" loading="lazy"></iframe>
        """
    )
    .padding()
}
