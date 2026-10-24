import WebKit

/// Finds where a loaded page's icon is, for Essentials and tab rows (spec §3.2).
@MainActor
enum FaviconFinder {
    /// The largest icon the page declares, skipping SVG, which images can't show. An Apple touch icon
    /// without a size counts as 180 pt, its usual size; any other icon without one, as 16 pt.
    /// Always returns a string: WebKit's async call fails when a script returns nothing.
    private static let script = """
        (() => {
          const size = (link) => {
            const declared = Math.max(0, ...(link.getAttribute('sizes') || '').split(/\\s+/)
              .map((value) => parseInt(value, 10) || 0));
            return declared || (/apple-touch-icon/i.test(link.rel) ? 180 : 16);
          };
          const links = Array.from(document.querySelectorAll(
            'link[rel~="icon" i], link[rel~="apple-touch-icon" i], link[rel~="apple-touch-icon-precomposed" i]'
          )).filter((link) => link.href && !/svg/i.test(link.type) && !/\\.svg([?#]|$)/i.test(link.href));
          links.sort((a, b) => size(b) - size(a));
          return links.length ? links[0].href : '';
        })()
        """

    /// The icon of the page shown in `webView`, or the site's `/favicon.ico` when the page declares none.
    static func favicon(in webView: WKWebView) async -> URL? {
        let declared = (try? await webView.evaluateJavaScript(script)) as? String
        if let declared, !declared.isEmpty, let url = URL(string: declared) { return url }
        return defaultFavicon(for: webView.url)
    }

    /// `/favicon.ico` at the root of a web page's site. Other pages, such as `about:blank`, have none.
    private static func defaultFavicon(for page: URL?) -> URL? {
        guard let page, let scheme = page.scheme, ["http", "https"].contains(scheme), let host = page.host() else {
            return nil
        }
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = page.port
        components.path = "/favicon.ico"
        return components.url
    }
}
