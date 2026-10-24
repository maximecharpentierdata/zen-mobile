/// Space management (spec §3.3, §3.7).
extension BrowserData {
    /// What to do with a space's tabs when the space is deleted.
    public enum DeletedSpaceTabs: Hashable, Sendable {
        /// Close them; they go to ``BrowserData/recentlyClosed``.
        case close
        /// Move them to the end of another space's sections.
        case moveTo(Space.ID)
    }

    /// Adds a space after the existing ones and returns its id.
    @discardableResult
    public mutating func addSpace(name: String, icon: String, accentColor: UInt32) -> Space.ID {
        let space = Space(name: name, icon: icon, accentColor: accentColor)
        setSpaces(spaces + [space], current: currentSpaceID)
        return space.id
    }

    /// Makes this space the current one.
    public mutating func selectSpace(_ id: Space.ID) throws {
        _ = try spaceIndex(id)
        setSpaces(spaces, current: id)
    }

    /// Renames a space and changes its icon and colour.
    public mutating func editSpace(_ id: Space.ID, name: String, icon: String, accentColor: UInt32) throws {
        try updateSpace(id) { space in
            space.name = name
            space.icon = icon
            space.accentColor = accentColor
        }
    }

    /// Moves a space to a new position. The index is clamped to the valid range.
    public mutating func moveSpace(_ id: Space.ID, to index: Int) throws {
        var newSpaces = spaces
        let currentIndex = try spaceIndex(id)
        let space = newSpaces.remove(at: currentIndex)
        newSpaces.insert(space, at: min(max(index, 0), newSpaces.count))
        setSpaces(newSpaces, current: currentSpaceID)
    }

    /// Deletes a space. The last space can't be deleted (spec §2, §3.7).
    public mutating func deleteSpace(_ id: Space.ID, tabs: DeletedSpaceTabs) throws {
        guard spaces.count > 1 else { throw ModelError.cannotDeleteLastSpace }
        let removedIndex = try spaceIndex(id)
        let removed = spaces[removedIndex]
        switch tabs {
        case .close:
            let closed = removed.pinned.flatMap(\.allTabs) + removed.regular
            addToRecentlyClosed(closed.map(Self.unpinned))
        case .moveTo(let targetID):
            guard targetID != id else { throw ModelError.spaceNotFound(targetID) }
            try updateSpace(targetID) { target in
                target.pinned += removed.pinned
                target.regular += removed.regular
            }
        }
        let remaining = spaces.filter { $0.id != id }
        let nextCurrent = currentSpaceID == id ? remaining[max(removedIndex - 1, 0)].id : currentSpaceID
        setSpaces(remaining, current: nextCurrent)
    }

    mutating func addToRecentlyClosed(_ tabs: [Tab]) {
        recentlyClosed = Array((tabs + recentlyClosed).prefix(Self.recentlyClosedLimit))
    }

    static func unpinned(_ tab: Tab) -> Tab {
        var tab = tab
        tab.pinnedURL = nil
        return tab
    }
}
