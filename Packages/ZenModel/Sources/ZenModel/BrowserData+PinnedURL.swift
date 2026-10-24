/// The URL that pinned tabs and Essentials keep, so they can go back to it (spec §2, §3.2).
extension BrowserData {
    /// Loads the tab's pinned URL again. Only pinned tabs and Essentials have one.
    public mutating func resetToPinnedURL(_ id: Tab.ID) throws {
        let pinnedURL = try pinnedTab(id).pinnedURL
        guard let pinnedURL else { return }
        try updateTab(id) { tab in
            tab.url = pinnedURL
            tab.title = ""
        }
    }

    /// Makes the page the tab shows now its pinned URL.
    public mutating func replacePinnedURL(_ id: Tab.ID) throws {
        let url = try pinnedTab(id).url
        guard let url else { return }
        try updateTab(id) { $0.pinnedURL = url }
    }

    /// The tab, when it is pinned or an Essential.
    private func pinnedTab(_ id: Tab.ID) throws -> Tab {
        guard let tab = tab(id) else { throw ModelError.tabNotFound(id) }
        switch location(of: id) {
        case .pinned, .essentials:
            return tab
        case .regular, nil:
            throw ModelError.invalidTabLocation(id)
        }
    }

    /// The tab, remembering its current URL as its pinned URL unless it already has one.
    static func keepingPinnedURL(_ tab: Tab) -> Tab {
        var tab = tab
        tab.pinnedURL = tab.pinnedURL ?? tab.url
        return tab
    }
}
