import WebKit
import ZenModel

/// Keeps one `WKWebView` per tab, created on first use (architecture §4).
///
/// Our own thin layer over WebKit (architecture §3): Mozilla's WebEngine is the reference, nothing is copied yet.
@MainActor
public final class WebViewStore {
    /// Called when a tab's page changes: its id, the URL now shown and the page title.
    public typealias PageChange = @MainActor (ZenModel.Tab.ID, URL?, String) -> Void
    /// Called when a loaded page's icon is found: the tab's id and where to load the icon from.
    public typealias FaviconChange = @MainActor (ZenModel.Tab.ID, URL?) -> Void

    private var pages: [ZenModel.Tab.ID: Page] = [:]
    private let onPageChange: PageChange
    private let onFaviconChange: FaviconChange

    /// Creates an empty store. `onPageChange` reports navigations and `onFaviconChange` page icons, so the
    /// model stays up to date.
    public init(onPageChange: @escaping PageChange, onFaviconChange: @escaping FaviconChange) {
        self.onPageChange = onPageChange
        self.onFaviconChange = onFaviconChange
    }

    /// The web view for a tab. A new one loads the tab's URL; an existing one is reused as it is.
    public func webView(for tab: ZenModel.Tab) -> WKWebView {
        page(for: tab).webView
    }

    /// The browser controls of a tab's page, for the page menu. Creates the page like ``webView(for:)``.
    public func navigation(for tab: ZenModel.Tab) -> PageNavigation {
        page(for: tab).navigation
    }

    /// Loads `url` in the tab's web view when it isn't already showing it.
    public func load(_ url: URL, in tab: ZenModel.Tab) {
        let webView = webView(for: tab)
        guard webView.url != url else { return }
        webView.load(URLRequest(url: url))
    }

    /// Whether the tab's page has an earlier page in its history.
    public func canGoBack(_ id: ZenModel.Tab.ID) -> Bool {
        pages[id]?.webView.canGoBack ?? false
    }

    /// Whether the tab's page has a later page in its history.
    public func canGoForward(_ id: ZenModel.Tab.ID) -> Bool {
        pages[id]?.webView.canGoForward ?? false
    }

    /// Goes to the previous page in the tab's history.
    public func goBack(_ id: ZenModel.Tab.ID) {
        pages[id]?.webView.goBack()
    }

    /// Goes to the next page in the tab's history.
    public func goForward(_ id: ZenModel.Tab.ID) {
        pages[id]?.webView.goForward()
    }

    /// Frees a tab's web view, for example when the tab closes or memory runs low.
    public func unload(_ id: ZenModel.Tab.ID) {
        pages[id]?.webView.stopLoading()
        pages[id] = nil
    }

    /// Frees the web views of every tab not in `keep`.
    public func unloadAll(except keep: Set<ZenModel.Tab.ID>) {
        for id in pages.keys where !keep.contains(id) {
            unload(id)
        }
    }

    private func page(for tab: ZenModel.Tab) -> Page {
        if let existing = pages[tab.id] { return existing }
        let webView = WKWebView(frame: .zero, configuration: Self.configuration())
        webView.allowsBackForwardNavigationGestures = true
        webView.isFindInteractionEnabled = true
        let navigation = PageNavigation(webView: webView)
        let observer = PageObserver(
            tabID: tab.id,
            navigation: navigation,
            onChange: onPageChange,
            onFavicon: onFaviconChange
        )
        webView.navigationDelegate = observer
        let page = Page(webView: webView, observer: observer, navigation: navigation)
        pages[tab.id] = page
        if let url = tab.url { webView.load(URLRequest(url: url)) }
        return page
    }

    private static func configuration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.websiteDataStore = .default()
        return configuration
    }
}

/// A tab's web view with the objects that follow it. The web view holds its delegate weakly, so the store keeps it.
@MainActor
private struct Page {
    let webView: WKWebView
    let observer: PageObserver
    let navigation: PageNavigation
}

/// Reports a web view's committed and finished navigations and the icon of each finished page.
/// It also applies the page's content mode.
@MainActor
private final class PageObserver: NSObject, WKNavigationDelegate {
    private let tabID: ZenModel.Tab.ID
    private let navigation: PageNavigation
    private let onChange: WebViewStore.PageChange
    private let onFavicon: WebViewStore.FaviconChange

    init(
        tabID: ZenModel.Tab.ID,
        navigation: PageNavigation,
        onChange: @escaping WebViewStore.PageChange,
        onFavicon: @escaping WebViewStore.FaviconChange
    ) {
        self.tabID = tabID
        self.navigation = navigation
        self.onChange = onChange
        self.onFavicon = onFavicon
    }

    /// Asks for the desktop or the mobile version of each site, as the page menu set it (spec §3.4).
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences
    ) async -> (WKNavigationActionPolicy, WKWebpagePreferences) {
        preferences.preferredContentMode = navigation.isDesktopSite ? .desktop : .mobile
        return (.allow, preferences)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation?) {
        onChange(tabID, webView.url, webView.title ?? "")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        onChange(tabID, webView.url, webView.title ?? "")
        let page = webView.url
        Task { [weak webView] in
            guard let webView else { return }
            let favicon = await FaviconFinder.favicon(in: webView)
            // A newer navigation reports its own icon; this one would belong to the previous page.
            guard webView.url == page else { return }
            onFavicon(tabID, favicon)
        }
    }
}
