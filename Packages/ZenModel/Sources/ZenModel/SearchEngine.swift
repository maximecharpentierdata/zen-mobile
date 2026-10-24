import Foundation

/// The engine used when typed text isn't an address (spec §3.6).
public enum SearchEngine: String, CaseIterable, Codable, Sendable {
    /// DuckDuckGo. The default.
    case duckDuckGo

    /// The results page for a query.
    public func searchURL(for query: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        switch self {
        case .duckDuckGo:
            components.host = "duckduckgo.com"
            components.path = "/"
        }
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        return components.url
    }
}
