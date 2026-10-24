/// Drag to reorder: moving a tab anywhere, across the divider, into folders and Essentials (spec §3.2).
extension BrowserData {
    /// Moves a tab to `destination`. Dropping above the divider or into Essentials pins the tab (it remembers its
    /// URL), dropping below the divider unpins it. The destination is checked before anything changes.
    public mutating func moveTab(_ id: Tab.ID, to destination: TabDestination) throws {
        guard let source = location(of: id) else { throw ModelError.tabNotFound(id) }
        try checkExists(destination)
        let index = insertionIndex(for: destination, movingFrom: source, tab: id)
        var tab = try removeTab(id)
        switch destination {
        case .essentials:
            essentials.insert(Self.keepingPinnedURL(tab), at: Self.clamp(index, count: essentials.count))
        case .pinned(let spaceID, let folderID, _):
            tab = Self.keepingPinnedURL(tab)
            try updateSpace(spaceID) { space in
                _ = PinnedTree.insert(.tab(tab), into: folderID, at: index, in: &space.pinned)
            }
        case .regular(let spaceID, _):
            try updateSpace(spaceID) { space in
                space.regular.insert(Self.unpinned(tab), at: Self.clamp(index, count: space.regular.count))
            }
        }
    }

    /// The destination that puts a dropped tab right before the tab with this id, in the same list.
    public func destination(before id: Tab.ID) -> TabDestination? {
        switch location(of: id) {
        case .essentials:
            return essentials.firstIndex { $0.id == id }.map { .essentials(index: $0) }
        case .pinned(let spaceID, let folderID):
            let items = PinnedTree.children(of: folderID, in: space(spaceID)?.pinned ?? [])
            return items?.firstIndex { $0.tab?.id == id }.map { .pinned(spaceID, folder: folderID, index: $0) }
        case .regular(let spaceID):
            return space(spaceID)?.regular.firstIndex { $0.id == id }.map { .regular(spaceID, index: $0) }
        case nil:
            return nil
        }
    }

    private func checkExists(_ destination: TabDestination) throws {
        switch destination {
        case .essentials:
            return
        case .pinned(let spaceID, let folderID, _):
            _ = try spaceIndex(spaceID)
            if let folderID, !PinnedTree.containsFolder(folderID, in: space(spaceID)?.pinned ?? []) {
                throw ModelError.folderNotFound(folderID)
            }
        case .regular(let spaceID, _):
            _ = try spaceIndex(spaceID)
        }
    }

    /// The destination index once the tab has left its list: one less when it moves down its own list.
    private func insertionIndex(for destination: TabDestination, movingFrom source: TabLocation, tab id: Tab.ID)
        -> Int
    {
        let index = destination.index
        guard let sourceIndex = sameList(as: destination, source: source)?.firstIndex(of: id) else { return index }
        return sourceIndex < index ? index - 1 : index
    }

    /// The ids in the destination list, with `nil` for folders, when the tab already is in that list.
    private func sameList(as destination: TabDestination, source: TabLocation) -> [Tab.ID?]? {
        switch destination {
        case .essentials:
            guard source == .essentials else { return nil }
            return essentials.map(\.id)
        case .pinned(let spaceID, let folderID, _):
            guard source == .pinned(spaceID, folder: folderID) else { return nil }
            return PinnedTree.children(of: folderID, in: space(spaceID)?.pinned ?? [])?.map(\.tab?.id)
        case .regular(let spaceID, _):
            guard source == .regular(spaceID) else { return nil }
            return space(spaceID)?.regular.map(\.id)
        }
    }
}
