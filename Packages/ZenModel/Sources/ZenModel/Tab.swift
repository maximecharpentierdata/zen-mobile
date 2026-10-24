import Foundation

/// A web page the user keeps open (spec §2).
public struct Tab: Identifiable, Hashable, Codable, Sendable {
    /// A tab's identifier.
    public typealias ID = Identifier<Tab>

    /// The tab's stable identifier.
    public let id: ID
    /// The page currently shown, or `nil` for a new empty tab.
    public var url: URL?
    /// The page title, or an empty string before the first load.
    public var title: String
    /// Where to load the site's icon from, if known.
    public var faviconURL: URL?
    /// When the user last opened this tab. Drives automatic clean-up (spec §3.2).
    public var lastAccessed: Date
    /// The URL a pinned tab can be reset to. `nil` while the tab isn't pinned.
    public var pinnedURL: URL?

    /// Creates a tab.
    public init(
        id: ID = ID(),
        url: URL? = nil,
        title: String = "",
        faviconURL: URL? = nil,
        lastAccessed: Date,
        pinnedURL: URL? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.faviconURL = faviconURL
        self.lastAccessed = lastAccessed
        self.pinnedURL = pinnedURL
    }
}
