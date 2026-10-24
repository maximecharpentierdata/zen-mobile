import SwiftUI
import WebKit

/// Shows a web view kept by ``WebViewStore`` inside SwiftUI.
public struct WebPage: UIViewRepresentable {
    private let webView: WKWebView
    private let onSwipe: @MainActor (PageSwipeEvent) -> Void
    private let onScroll: @MainActor (PageScrollEvent) -> Void

    /// Wraps an existing web view. The store owns it; this view only displays it.
    /// `onSwipe` reports sideways swipes on the page and `onScroll` vertical drags (spec §3.4).
    public init(
        webView: WKWebView,
        onSwipe: @escaping @MainActor (PageSwipeEvent) -> Void,
        onScroll: @escaping @MainActor (PageScrollEvent) -> Void
    ) {
        self.webView = webView
        self.onSwipe = onSwipe
        self.onScroll = onScroll
    }

    /// Follows the page's vertical drags while this view shows it.
    public func makeCoordinator() -> PageScrollObserver {
        PageScrollObserver(onScroll: onScroll)
    }

    /// Returns the stored web view, with the swipe recognizer attached and its scrolling followed.
    public func makeUIView(context: Context) -> WKWebView {
        attachSwipe(to: webView)
        context.coordinator.attach(to: webView.scrollView)
        return webView
    }

    /// Keeps the handlers current; the web view manages its own content.
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        attachSwipe(to: uiView)
        context.coordinator.onScroll = onScroll
    }

    /// Stops following the page's scrolling: the web view lives on in the store.
    public static func dismantleUIView(_ uiView: WKWebView, coordinator: PageScrollObserver) {
        coordinator.detach()
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
