import Foundation

/// Opening, closing and updating tabs (spec §3.2, §3.5, §3.6).
extension BrowserData {
    /// Creates a tab at the top of a space's regular tabs and returns its id (spec §3.5).
    @discardableResult
    public mutating func newTab(url: URL? = nil, in spaceID: Space.ID, now: Date) throws -> Tab.ID {
        let tab = Tab(url: url, lastAccessed: now)
        try updateSpace(spaceID) { $0.regular.insert(tab, at: 0) }
        return tab.id
    }

    /// Closes a tab, wherever it is, and keeps it in ``recentlyClosed``.
    public mutating func closeTab(_ id: Tab.ID) throws {
        let tab = try removeTab(id)
        addToRecentlyClosed([Self.unpinned(tab)])
    }

    /// Reopens a recently closed tab at the top of the current space's regular tabs.
    public mutating func restoreClosedTab(_ id: Tab.ID, now: Date) throws {
        guard let index = recentlyClosed.firstIndex(where: { $0.id == id }) else { throw ModelError.tabNotFound(id) }
        var tab = recentlyClosed.remove(at: index)
        tab.lastAccessed = now
        try updateSpace(currentSpaceID) { $0.regular.insert(tab, at: 0) }
    }

    /// Records that the user opened the tab now. This resets its automatic clean-up timer.
    public mutating func recordAccess(_ id: Tab.ID, now: Date) throws {
        try updateTab(id) { $0.lastAccessed = now }
    }

    /// Updates what the tab shows after a navigation.
    public mutating func updatePage(_ id: Tab.ID, url: URL?, title: String, faviconURL: URL?) throws {
        try updateTab(id) { tab in
            tab.url = url
            tab.title = title
            tab.faviconURL = faviconURL
        }
    }

    /// Closes the regular tabs not opened within ``autoCloseDelay`` and returns their ids (spec §3.2).
    /// Pinned tabs, tabs in folders and Essentials are never closed this way.
    @discardableResult
    public mutating func closeStaleTabs(now: Date) -> [Tab.ID] {
        guard let interval = autoCloseDelay.interval else { return [] }
        let limit = now.addingTimeInterval(-interval)
        var closed: [Tab] = []
        var newSpaces = spaces
        for index in newSpaces.indices {
            let (stale, fresh) = newSpaces[index].regular.partitioned { $0.lastAccessed < limit }
            closed += stale
            newSpaces[index].regular = fresh
        }
        setSpaces(newSpaces, current: currentSpaceID)
        addToRecentlyClosed(closed)
        return closed.map(\.id)
    }

    /// Removes the tab from wherever it is and returns it.
    mutating func removeTab(_ id: Tab.ID) throws -> Tab {
        if let index = essentials.firstIndex(where: { $0.id == id }) {
            return essentials.remove(at: index)
        }
        for space in spaces {
            var removed: Tab?
            try updateSpace(space.id) { candidate in
                if let index = candidate.regular.firstIndex(where: { $0.id == id }) {
                    removed = candidate.regular.remove(at: index)
                } else {
                    removed = PinnedTree.removeTab(id, from: &candidate.pinned)
                }
            }
            if let removed { return removed }
        }
        throw ModelError.tabNotFound(id)
    }

    /// Applies `change` to the tab with this id, wherever it is.
    mutating func updateTab(_ id: Tab.ID, _ change: (inout Tab) -> Void) throws {
        if let index = essentials.firstIndex(where: { $0.id == id }) {
            change(&essentials[index])
            return
        }
        for space in spaces {
            var found = false
            try updateSpace(space.id) { candidate in
                if let index = candidate.regular.firstIndex(where: { $0.id == id }) {
                    change(&candidate.regular[index])
                    found = true
                } else {
                    found = PinnedTree.updateTab(id, in: &candidate.pinned, change)
                }
            }
            if found { return }
        }
        throw ModelError.tabNotFound(id)
    }
}

extension Array {
    /// Splits the array into the elements matching `isIncluded` and the others, keeping their order.
    func partitioned(by isIncluded: (Element) -> Bool) -> (matching: [Element], others: [Element]) {
        var matching: [Element] = []
        var others: [Element] = []
        for element in self {
            if isIncluded(element) {
                matching.append(element)
            } else {
                others.append(element)
            }
        }
        return (matching, others)
    }
}
