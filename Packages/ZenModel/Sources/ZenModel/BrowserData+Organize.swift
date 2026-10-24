/// Pinning, Essentials, reordering and moving tabs between spaces (spec §3.2).
extension BrowserData {
    /// Pins a regular tab: it moves into its space's pinned section and remembers its URL as the pinned URL.
    /// The tab goes into `folderID` (the root when `nil`), at `index`, clamped to the valid range.
    public mutating func pin(_ id: Tab.ID, into folderID: Folder.ID? = nil, at index: Int = .max) throws {
        guard case .regular(let spaceID) = location(of: id) else { throw ModelError.invalidTabLocation(id) }
        if let folderID, !PinnedTree.containsFolder(folderID, in: space(spaceID)?.pinned ?? []) {
            throw ModelError.folderNotFound(folderID)
        }
        var tab = try removeTab(id)
        tab.pinnedURL = tab.url
        try updateSpace(spaceID) { space in
            _ = PinnedTree.insert(.tab(tab), into: folderID, at: index, in: &space.pinned)
        }
    }

    /// Unpins a tab: it moves to the top of its space's regular tabs and forgets its pinned URL.
    public mutating func unpin(_ id: Tab.ID) throws {
        guard case .pinned(let spaceID, _) = location(of: id) else { throw ModelError.invalidTabLocation(id) }
        let removed = try removeTab(id)
        let tab = Self.unpinned(removed)
        try updateSpace(spaceID) { $0.regular.insert(tab, at: 0) }
    }

    /// Moves a tab from a space into Essentials, at the end.
    public mutating func addToEssentials(_ id: Tab.ID) throws {
        guard let location = location(of: id), location != .essentials else {
            throw ModelError.invalidTabLocation(id)
        }
        let removed = try removeTab(id)
        essentials.append(Self.unpinned(removed))
    }

    /// Moves a tab out of Essentials, to the top of a space's regular tabs.
    public mutating func removeFromEssentials(_ id: Tab.ID, to spaceID: Space.ID) throws {
        guard location(of: id) == .essentials else { throw ModelError.invalidTabLocation(id) }
        _ = try spaceIndex(spaceID)
        let tab = try removeTab(id)
        try updateSpace(spaceID) { $0.regular.insert(tab, at: 0) }
    }

    /// Moves a tab within Essentials. The index is clamped to the valid range.
    public mutating func moveEssential(_ id: Tab.ID, to index: Int) throws {
        guard location(of: id) == .essentials else { throw ModelError.invalidTabLocation(id) }
        let tab = try removeTab(id)
        essentials.insert(tab, at: Self.clamp(index, count: essentials.count))
    }

    /// Moves a regular tab within its space's regular tabs. The index is clamped to the valid range.
    public mutating func moveRegularTab(_ id: Tab.ID, to index: Int) throws {
        guard case .regular(let spaceID) = location(of: id) else { throw ModelError.invalidTabLocation(id) }
        let tab = try removeTab(id)
        try updateSpace(spaceID) { $0.regular.insert(tab, at: Self.clamp(index, count: $0.regular.count)) }
    }

    /// Moves a pinned tab within its space's pinned section, into `folderID` (the root when `nil`).
    public mutating func movePinnedTab(_ id: Tab.ID, into folderID: Folder.ID?, at index: Int) throws {
        guard case .pinned(let spaceID, _) = location(of: id) else { throw ModelError.invalidTabLocation(id) }
        if let folderID, !PinnedTree.containsFolder(folderID, in: space(spaceID)?.pinned ?? []) {
            throw ModelError.folderNotFound(folderID)
        }
        let tab = try removeTab(id)
        try updateSpace(spaceID) { space in
            _ = PinnedTree.insert(.tab(tab), into: folderID, at: index, in: &space.pinned)
        }
    }

    /// Moves a tab to another space, into the same kind of section: regular tabs go first in the regular tabs,
    /// pinned tabs go last at the root of the pinned section.
    public mutating func moveTab(_ id: Tab.ID, toSpace targetID: Space.ID) throws {
        _ = try spaceIndex(targetID)
        switch location(of: id) {
        case .regular:
            let tab = try removeTab(id)
            try updateSpace(targetID) { $0.regular.insert(tab, at: 0) }
        case .pinned:
            let tab = try removeTab(id)
            try updateSpace(targetID) { $0.pinned.append(.tab(tab)) }
        case .essentials, nil:
            throw ModelError.invalidTabLocation(id)
        }
    }

    static func clamp(_ index: Int, count: Int) -> Int {
        min(max(index, 0), count)
    }
}
