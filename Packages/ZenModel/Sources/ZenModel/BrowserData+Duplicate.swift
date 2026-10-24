import Foundation

/// Duplicating a tab from its context menu (spec §3.2).
extension BrowserData {
    /// Copies a tab, with a new id, right after the original in the same place (Essentials, the same folder
    /// of the pinned section, or the regular tabs), and returns the copy's id. A pinned copy keeps the
    /// pinned URL.
    @discardableResult
    public mutating func duplicateTab(_ id: Tab.ID, now: Date) throws -> Tab.ID {
        guard let original = tab(id), let location = location(of: id) else { throw ModelError.tabNotFound(id) }
        let copy = Tab(
            url: original.url,
            title: original.title,
            faviconURL: original.faviconURL,
            lastAccessed: now,
            pinnedURL: original.pinnedURL
        )
        switch location {
        case .essentials:
            guard let index = essentials.firstIndex(where: { $0.id == id }) else { throw ModelError.tabNotFound(id) }
            essentials.insert(copy, at: index + 1)
        case .regular(let spaceID):
            try updateSpace(spaceID) { space in
                guard let index = space.regular.firstIndex(where: { $0.id == id }) else {
                    throw ModelError.tabNotFound(id)
                }
                space.regular.insert(copy, at: index + 1)
            }
        case .pinned(let spaceID, _):
            try updateSpace(spaceID) { space in
                guard PinnedTree.insert(.tab(copy), after: id, in: &space.pinned) else {
                    throw ModelError.tabNotFound(id)
                }
            }
        }
        return copy.id
    }
}
