/// Pure helpers over a pinned tree (`[PinnedItem]`), recursing into folders.
enum PinnedTree {
    /// Removes the tab with this id from the tree and returns it, or returns `nil` if it isn't there.
    static func removeTab(_ id: Tab.ID, from items: inout [PinnedItem]) -> Tab? {
        for index in items.indices {
            switch items[index] {
            case .tab(let tab) where tab.id == id:
                items.remove(at: index)
                return tab
            case .tab:
                continue
            case .folder(var folder):
                if let tab = removeTab(id, from: &folder.children) {
                    items[index] = .folder(folder)
                    return tab
                }
            }
        }
        return nil
    }

    /// Removes the folder with this id from the tree and returns it, or returns `nil` if it isn't there.
    static func removeFolder(_ id: Folder.ID, from items: inout [PinnedItem]) -> Folder? {
        for index in items.indices {
            guard case .folder(var folder) = items[index] else { continue }
            if folder.id == id {
                items.remove(at: index)
                return folder
            }
            if let found = removeFolder(id, from: &folder.children) {
                items[index] = .folder(folder)
                return found
            }
        }
        return nil
    }

    /// Applies `change` to the folder with this id. Returns `false` if the folder isn't in the tree.
    static func updateFolder(_ id: Folder.ID, in items: inout [PinnedItem], _ change: (inout Folder) -> Void) -> Bool {
        for index in items.indices {
            guard case .folder(var folder) = items[index] else { continue }
            if folder.id == id {
                change(&folder)
                items[index] = .folder(folder)
                return true
            }
            if updateFolder(id, in: &folder.children, change) {
                items[index] = .folder(folder)
                return true
            }
        }
        return false
    }

    /// Applies `change` to the tab with this id. Returns `false` if the tab isn't in the tree.
    static func updateTab(_ id: Tab.ID, in items: inout [PinnedItem], _ change: (inout Tab) -> Void) -> Bool {
        for index in items.indices {
            switch items[index] {
            case .tab(var tab) where tab.id == id:
                change(&tab)
                items[index] = .tab(tab)
                return true
            case .tab:
                continue
            case .folder(var folder):
                if updateTab(id, in: &folder.children, change) {
                    items[index] = .folder(folder)
                    return true
                }
            }
        }
        return false
    }

    /// Inserts `item` into the folder with this id, or at the root when `folderID` is `nil`.
    /// The index is clamped to the valid range. Returns `false` if the folder isn't in the tree.
    static func insert(_ item: PinnedItem, into folderID: Folder.ID?, at index: Int, in items: inout [PinnedItem])
        -> Bool
    {
        guard let folderID else {
            items.insert(item, at: clamp(index, count: items.count))
            return true
        }
        return updateFolder(folderID, in: &items) { folder in
            folder.children.insert(item, at: clamp(index, count: folder.children.count))
        }
    }

    /// Whether a folder with this id exists in the tree.
    static func containsFolder(_ id: Folder.ID, in items: [PinnedItem]) -> Bool {
        items.contains { item in
            guard let folder = item.folder else { return false }
            return folder.id == id || containsFolder(id, in: folder.children)
        }
    }

    private static func clamp(_ index: Int, count: Int) -> Int {
        min(max(index, 0), count)
    }
}
