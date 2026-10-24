import Foundation

/// The engine used when typed text isn't an address (spec §3.6).
public enum SearchEngine: String, CaseIterable, Codable, Sendable {
    /// Google. The default, chosen on 2026-10-24.
    case google

    /// The results page for a query.
    public func searchURL(for query: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        switch self {
        case .google:
            components.host = "www.google.com"
            components.path = "/search"
        }
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        return components.url
    }
}
