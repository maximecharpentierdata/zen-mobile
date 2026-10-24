/// Finding tabs.
extension BrowserData {
    /// Where the tab with this id is, or `nil` if no tab has it.
    public func location(of id: Tab.ID) -> TabLocation? {
        if essentials.contains(where: { $0.id == id }) { return .essentials }
        for space in spaces {
            if space.regular.contains(where: { $0.id == id }) { return .regular(space.id) }
            if let folder = Self.pinnedLocation(of: id, in: space.pinned, folder: nil) {
                return .pinned(space.id, folder: folder)
            }
        }
        return nil
    }

    /// The ids of every open tab: Essentials, pinned and regular tabs of all spaces. Closed tabs aren't included.
    public var allTabIDs: Set<Tab.ID> {
        let pinned = spaces.flatMap { $0.pinned.flatMap(\.allTabs) }
        return Set((essentials + pinned + spaces.flatMap(\.regular)).map(\.id))
    }

    /// The tab with this id, wherever it is.
    public func tab(_ id: Tab.ID) -> Tab? {
        let pinned = spaces.flatMap { $0.pinned.flatMap(\.allTabs) }
        let all = essentials + pinned + spaces.flatMap(\.regular)
        return all.first { $0.id == id }
    }

    /// Returns `.some(folderID)` when the tab is in this tree (`.some(nil)` at the root), or `nil` when it isn't.
    private static func pinnedLocation(of id: Tab.ID, in items: [PinnedItem], folder: Folder.ID?) -> Folder.ID?? {
        for item in items {
            switch item {
            case .tab(let tab) where tab.id == id:
                return .some(folder)
            case .tab:
                continue
            case .folder(let child):
                if let found = pinnedLocation(of: id, in: child.children, folder: child.id) { return found }
            }
        }
        return nil
    }
}
