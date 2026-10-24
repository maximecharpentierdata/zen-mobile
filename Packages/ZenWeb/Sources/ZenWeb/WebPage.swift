import SwiftUI
import WebKit

/// Shows a web view kept by ``WebViewStore`` inside SwiftUI.
public struct WebPage: UIViewRepresentable {
    private let webView: WKWebView
    private let onSwipe: @MainActor (PageSwipeEvent) -> Void
    private let onScroll: @MainActor (PageScrollEvent) -> Void
    private let contentInsets: UIEdgeInsets

    /// Wraps an existing web view. The store owns it; this view only displays it.
    /// `contentInsets` keeps the page's top and end clear of the status bar and the page bar, which float over it.
    /// `onSwipe` reports sideways swipes on the page and `onScroll` vertical drags (spec §3.4).
    public init(
        webView: WKWebView,
        contentInsets: UIEdgeInsets,
        onSwipe: @escaping @MainActor (PageSwipeEvent) -> Void,
        onScroll: @escaping @MainActor (PageScrollEvent) -> Void
    ) {
        self.webView = webView
        self.contentInsets = contentInsets
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
        // The insets come from SwiftUI's layout, so UIKit must not add the safe area on top of them.
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        applyInsets(to: webView.scrollView)
        context.coordinator.attach(to: webView.scrollView)
        return webView
    }

    /// Keeps the handlers current; the web view manages its own content.
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        attachSwipe(to: uiView)
        applyInsets(to: uiView.scrollView)
        context.coordinator.onScroll = onScroll
    }

    /// Stops following the page's scrolling: the web view lives on in the store.
    public static func dismantleUIView(_ uiView: WKWebView, coordinator: PageScrollObserver) {
        coordinator.detach()
    }

    /// A page shown at its top stays at its top, so the larger top inset doesn't leave its start under the status bar.
    private func applyInsets(to scrollView: UIScrollView) {
        let old = scrollView.contentInset
        guard old != contentInsets else { return }
        let wasAtTop = scrollView.contentOffset.y <= -old.top
        scrollView.contentInset = contentInsets
        scrollView.verticalScrollIndicatorInsets = contentInsets
        if wasAtTop { scrollView.contentOffset.y = -contentInsets.top }
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
