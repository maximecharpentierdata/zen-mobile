import Foundation

/// Turns what the user typed in the address field into the URL to load (spec §3.4, §3.6).
public enum AddressInput {
    /// The URL for `text`: the text itself when it is a web address (with `https://` added when it has no
    /// scheme), otherwise a search with `engine`. Returns `nil` for blank text.
    public static func url(for text: String, engine: SearchEngine) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = webAddress(trimmed) { return url }
        return engine.searchURL(for: trimmed)
    }

    private static func webAddress(_ text: String) -> URL? {
        guard !text.contains(" ") else { return nil }
        if let url = URL(string: text), isWeb(url) {
            return url
        }
        guard looksLikeHost(text), let url = URL(string: "https://\(text)"), isWeb(url) else { return nil }
        return url
    }

    private static func isWeb(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(), let host = url.host(), !host.isEmpty else { return false }
        return scheme == "http" || scheme == "https"
    }

    /// `example.com`, `example.com/path`, `localhost:8080` or an IPv4 address, but not `hello` or `what?`.
    private static func looksLikeHost(_ text: String) -> Bool {
        let host = text.split(separator: "/", maxSplits: 1).first.map(String.init) ?? text
        let hostWithoutPort = host.split(separator: ":").first.map(String.init) ?? host
        if hostWithoutPort == "localhost" { return true }
        let labels = hostWithoutPort.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count >= 2, labels.allSatisfy({ !$0.isEmpty }) else { return false }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        return labels.allSatisfy { $0.unicodeScalars.allSatisfy(allowed.contains) }
    }
}
