import UIKit
import WebKit

/// Pull to refresh on a web page: pulling down when the page is already at the top reloads it (spec §3.4).
///
/// It follows the web view's `isLoading` through key-value observation, so the spinner stops when the reload
/// finishes or fails, whichever navigation callback reports it.
final class PageRefreshControl: UIRefreshControl {
    private weak var webView: WKWebView?
    private var observation: NSKeyValueObservation?

    init(webView: WKWebView) {
        self.webView = webView
        super.init()
        addTarget(self, action: #selector(reload), for: .valueChanged)
        observation = webView.observe(\.isLoading) { [weak self] _, _ in
            MainActor.assumeIsolated { self?.stopUnlessLoading() }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    /// A page with nothing to reload, such as a new tab with no address, doesn't start loading, so the spinner
    /// stops at once.
    @objc private func reload() {
        webView?.reload()
        stopUnlessLoading()
    }

    private func stopUnlessLoading() {
        if webView?.isLoading != true { endRefreshing() }
    }
}
