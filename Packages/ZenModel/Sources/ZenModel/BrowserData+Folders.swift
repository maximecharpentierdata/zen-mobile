/// Folders in a space's pinned section (spec §2, §3.2).
extension BrowserData {
    /// Creates an empty folder at the end of `parentID` (the pinned root when `nil`) and returns its id.
    @discardableResult
    public mutating func createFolder(named name: String, in spaceID: Space.ID, parent parentID: Folder.ID? = nil)
        throws -> Folder.ID
    {
        let folder = Folder(name: name)
        try updateSpace(spaceID) { space in
            guard PinnedTree.insert(.folder(folder), into: parentID, at: .max, in: &space.pinned) else {
                throw ModelError.folderNotFound(parentID ?? folder.id)
            }
        }
        return folder.id
    }

    /// Renames a folder.
    public mutating func renameFolder(_ id: Folder.ID, to name: String) throws {
        try updateFolder(id) { $0.name = name }
    }

    /// Expands a collapsed folder, or collapses an expanded one.
    public mutating func toggleFolder(_ id: Folder.ID) throws {
        try updateFolder(id) { $0.isExpanded.toggle() }
    }

    /// Deletes a folder. Its content takes the folder's place, so no tab is lost.
    public mutating func deleteFolder(_ id: Folder.ID) throws {
        let spaceID = try spaceContaining(id)
        try updateSpace(spaceID) { space in
            space.pinned = Self.replacingFolder(id, withChildrenIn: space.pinned)
        }
    }

    /// Moves a folder into `parentID` (the root when `nil`) of the same space, at `index`.
    /// A folder can't move into itself or one of its descendants.
    public mutating func moveFolder(_ id: Folder.ID, into parentID: Folder.ID?, at index: Int) throws {
        let spaceID = try spaceContaining(id)
        try updateSpace(spaceID) { space in
            guard let folder = PinnedTree.removeFolder(id, from: &space.pinned) else {
                throw ModelError.folderNotFound(id)
            }
            if let parentID, parentID == id || PinnedTree.containsFolder(parentID, in: folder.children) {
                throw ModelError.folderCycle
            }
            guard PinnedTree.insert(.folder(folder), into: parentID, at: index, in: &space.pinned) else {
                throw ModelError.folderNotFound(parentID ?? id)
            }
        }
    }

    private mutating func updateFolder(_ id: Folder.ID, _ change: (inout Folder) -> Void) throws {
        let spaceID = try spaceContaining(id)
        try updateSpace(spaceID) { space in
            _ = PinnedTree.updateFolder(id, in: &space.pinned, change)
        }
    }

    private func spaceContaining(_ id: Folder.ID) throws -> Space.ID {
        guard let space = spaces.first(where: { PinnedTree.containsFolder(id, in: $0.pinned) }) else {
            throw ModelError.folderNotFound(id)
        }
        return space.id
    }

    private static func replacingFolder(_ id: Folder.ID, withChildrenIn items: [PinnedItem]) -> [PinnedItem] {
        items.flatMap { item -> [PinnedItem] in
            guard case .folder(var folder) = item else { return [item] }
            if folder.id == id { return folder.children }
            folder.children = replacingFolder(id, withChildrenIn: folder.children)
            return [.folder(folder)]
        }
    }
}
