import SwiftUI
import WebKit

/// Shows a web view kept by ``WebViewStore`` inside SwiftUI.
public struct WebPage: UIViewRepresentable {
    private let webView: WKWebView
    private let onSwipe: @MainActor (PageSwipeEvent) -> Void

    /// Wraps an existing web view. The store owns it; this view only displays it.
    /// `onSwipe` reports sideways swipes on the page (spec §3.4).
    public init(webView: WKWebView, onSwipe: @escaping @MainActor (PageSwipeEvent) -> Void) {
        self.webView = webView
        self.onSwipe = onSwipe
    }

    /// Returns the stored web view, with the swipe recognizer attached.
    public func makeUIView(context: Context) -> WKWebView {
        attachSwipe(to: webView)
        return webView
    }

    /// Keeps the swipe handler current; the web view manages its own content.
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        attachSwipe(to: uiView)
    }

    /// The web view outlives this view, so its recognizer is added once and then reused.
    private func attachSwipe(to webView: WKWebView) {
        let existing = webView.gestureRecognizers?.lazy.compactMap { $0 as? PageSwipeRecognizer }.first
        if let existing {
            existing.onSwipe = onSwipe
        } else {
            webView.addGestureRecognizer(PageSwipeRecognizer(onSwipe: onSwipe))
        }
    }
}
