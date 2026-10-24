import Foundation

/// Suggestions and inline completion for the address field, drawn from the user's own pages (spec §3.4, §3.6).
public enum AddressAutocomplete {
    /// The most suggestions shown with the field. *(proposal)*
    public static let suggestionLimit = 4

    /// How well a page matches, best first.
    private enum Rank: CaseIterable {
        case addressPrefix
        case addressContains
        case title
    }

    /// The pages among `candidates` that match `text`, at most `limit`: first those whose address starts with
    /// it, then those whose address contains it, then those whose title contains it, each in `candidates`
    /// order. A URL is suggested once. Case, the scheme and `www.` don't matter.
    public static func suggestions(for text: String, in candidates: [Tab], limit: Int = suggestionLimit) -> [Tab] {
        let query = normalized(text)
        guard !query.isEmpty else { return [] }
        let matches = candidates.compactMap { tab -> (tab: Tab, url: URL, rank: Rank)? in
            guard let url = tab.url, let rank = rank(of: tab, at: url, for: query) else { return nil }
            return (tab, url, rank)
        }
        let ordered = Rank.allCases.flatMap { rank in matches.filter { $0.rank == rank } }
        var seen = Set<URL>()
        return Array(ordered.filter { seen.insert($0.url).inserted }.map(\.tab).prefix(limit))
    }

    /// `text` followed by the rest of the first address in `candidates` that starts with it, or `nil` when none
    /// does or the text already is a whole address. It finishes the host first, as in Safari; once the text
    /// has a `/`, it finishes the whole address. Text with a space is a search, so it is never completed.
    public static func completion(for text: String, in candidates: [Tab]) -> String? {
        guard !text.contains(where: \.isWhitespace) else { return nil }
        let query = normalized(text)
        guard !query.isEmpty else { return nil }
        let completesPath = query.contains("/")
        for url in candidates.compactMap(\.url) {
            let address = displayAddress(of: url)
            let target = completesPath ? address : host(of: address)
            guard target.count > query.count, target.lowercased().hasPrefix(query) else { continue }
            return text + target.dropFirst(query.count)
        }
        return nil
    }

    /// The address as the field shows and matches it: without the scheme, `www.` or a trailing `/`.
    public static func displayAddress(of url: URL) -> String {
        var address = dropping(["https://", "http://", "www."], from: url.absoluteString)
        if address.hasSuffix("/") { address.removeLast() }
        return address
    }

    private static func rank(of tab: Tab, at url: URL, for query: String) -> Rank? {
        let address = displayAddress(of: url).lowercased()
        if address.hasPrefix(query) { return .addressPrefix }
        if address.contains(query) { return .addressContains }
        if tab.title.lowercased().contains(query) { return .title }
        return nil
    }

    /// The typed text as it is matched: trimmed, lowercased, without a scheme or `www.`.
    private static func normalized(_ text: String) -> String {
        let lowered = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return dropping(["https://", "http://", "www."], from: lowered)
    }

    /// `text` without each of `prefixes` it starts with, removed in order.
    private static func dropping(_ prefixes: [String], from text: String) -> String {
        prefixes.reduce(text) { result, prefix in
            result.hasPrefix(prefix) ? String(result.dropFirst(prefix.count)) : result
        }
    }

    private static func host(of address: String) -> String {
        address.split(separator: "/", maxSplits: 1).first.map(String.init) ?? address
    }
}
