import Observation
import WebKit

/// The browser controls of one page, for the page menu (spec §3.4).
///
/// It follows the web view through key-value observation rather than navigation callbacks, so back and forward
/// stay right after same-document navigations, which report no navigation.
@MainActor
@Observable
public final class PageNavigation {
    /// Whether the page has an earlier entry in its history.
    public private(set) var canGoBack = false
    /// Whether the page has a later entry in its history.
    public private(set) var canGoForward = false
    /// Whether the page asks sites for their desktop version. Not saved: a freed page comes back as mobile.
    public private(set) var isDesktopSite = false

    @ObservationIgnored private weak var webView: WKWebView?
    @ObservationIgnored private var observations: [NSKeyValueObservation] = []

    init(webView: WKWebView) {
        self.webView = webView
        observations = [
            webView.observe(\.canGoBack) { [weak self] _, _ in MainActor.assumeIsolated { self?.refresh() } },
            webView.observe(\.canGoForward) { [weak self] _, _ in MainActor.assumeIsolated { self?.refresh() } },
        ]
        refresh()
    }

    /// Goes to the previous page in the history.
    public func goBack() {
        webView?.goBack()
    }

    /// Goes to the next page in the history.
    public func goForward() {
        webView?.goForward()
    }

    /// Loads the page again.
    public func reload() {
        webView?.reload()
    }

    /// Shows the system find bar over the page.
    public func findOnPage() {
        webView?.findInteraction?.presentFindNavigator(showingReplace: false)
    }

    /// Switches between the desktop and the mobile version of the site, then reloads so the site sees the change.
    public func toggleDesktopSite() {
        isDesktopSite.toggle()
        webView?.reload()
    }

    private func refresh() {
        canGoBack = webView?.canGoBack ?? false
        canGoForward = webView?.canGoForward ?? false
    }
}
