import WebKit
import ZenModel

/// Keeps one `WKWebView` per tab, created on first use (architecture §4).
///
/// Our own thin layer over WebKit (architecture §3): Mozilla's WebEngine is the reference, nothing is copied yet.
@MainActor
public final class WebViewStore {
    /// Called when a tab's page changes: its id, the URL now shown and the page title.
    public typealias PageChange = @MainActor (ZenModel.Tab.ID, URL?, String) -> Void

    private var webViews: [ZenModel.Tab.ID: WKWebView] = [:]
    private var observers: [ZenModel.Tab.ID: PageObserver] = [:]
    private let onPageChange: PageChange

    /// Creates an empty store. `onPageChange` reports navigations so the model stays up to date.
    public init(onPageChange: @escaping PageChange) {
        self.onPageChange = onPageChange
    }

    /// The web view for a tab. A new one loads the tab's URL; an existing one is reused as it is.
    public func webView(for tab: ZenModel.Tab) -> WKWebView {
        if let existing = webViews[tab.id] { return existing }
        let webView = WKWebView(frame: .zero, configuration: Self.configuration())
        webView.allowsBackForwardNavigationGestures = true
        let observer = PageObserver(tabID: tab.id, onChange: onPageChange)
        webView.navigationDelegate = observer
        webViews[tab.id] = webView
        observers[tab.id] = observer
        if let url = tab.url { webView.load(URLRequest(url: url)) }
        return webView
    }

    /// Loads `url` in the tab's web view when it isn't already showing it.
    public func load(_ url: URL, in tab: ZenModel.Tab) {
        let webView = webView(for: tab)
        guard webView.url != url else { return }
        webView.load(URLRequest(url: url))
    }

    /// Frees a tab's web view, for example when the tab closes or memory runs low.
    public func unload(_ id: ZenModel.Tab.ID) {
        webViews[id]?.stopLoading()
        webViews[id] = nil
        observers[id] = nil
    }

    /// Frees the web views of every tab not in `keep`.
    public func unloadAll(except keep: Set<ZenModel.Tab.ID>) {
        for id in webViews.keys where !keep.contains(id) {
            unload(id)
        }
    }

    private static func configuration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.websiteDataStore = .default()
        return configuration
    }
}

/// Reports a web view's committed and finished navigations.
@MainActor
private final class PageObserver: NSObject, WKNavigationDelegate {
    private let tabID: ZenModel.Tab.ID
    private let onChange: WebViewStore.PageChange

    init(tabID: ZenModel.Tab.ID, onChange: @escaping WebViewStore.PageChange) {
        self.tabID = tabID
        self.onChange = onChange
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation?) {
        onChange(tabID, webView.url, webView.title ?? "")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        onChange(tabID, webView.url, webView.title ?? "")
    }
}
