import SwiftUI
import WebKit

/// Shows a web view kept by ``WebViewStore`` inside SwiftUI.
public struct WebPage: UIViewRepresentable {
    private let webView: WKWebView

    /// Wraps an existing web view. The store owns it; this view only displays it.
    public init(webView: WKWebView) {
        self.webView = webView
    }

    /// Returns the stored web view.
    public func makeUIView(context: Context) -> WKWebView {
        webView
    }

    /// Nothing to update: the web view manages its own content.
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
}
