import Foundation
import ZenModel

/// The tab and folder actions of the long-press menus (spec §3.2).
extension BrowserState {
    /// Pins a regular tab at the end of its space's pinned section.
    public func pin(_ id: Tab.ID) {
        perform { try $0.pin(id) }
    }

    /// Unpins a tab: it goes to the top of its space's regular tabs.
    public func unpin(_ id: Tab.ID) {
        perform { try $0.unpin(id) }
    }

    /// Moves a tab into a folder of its space, at the end. A regular tab becomes pinned.
    public func moveTab(_ id: Tab.ID, toFolder folderID: Folder.ID) {
        perform { try Self.move(id, into: folderID, in: &$0) }
    }

    /// Creates a folder at the end of the tab's space's pinned section and moves the tab into it. Does nothing
    /// when `name` is blank.
    public func moveTabToNewFolder(_ id: Tab.ID, named name: String) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        perform { data in
            let spaceID: Space.ID
            switch data.location(of: id) {
            case .regular(let space), .pinned(let space, _):
                spaceID = space
            case .essentials, nil:
                throw ModelError.invalidTabLocation(id)
            }
            let folderID = try data.createFolder(named: name, in: spaceID)
            try Self.move(id, into: folderID, in: &data)
        }
    }

    private static func move(_ id: Tab.ID, into folderID: Folder.ID, in data: inout BrowserData) throws {
        switch data.location(of: id) {
        case .regular:
            try data.pin(id, into: folderID)
        case .pinned:
            try data.movePinnedTab(id, into: folderID, at: .max)
        case .essentials, nil:
            throw ModelError.invalidTabLocation(id)
        }
    }

    /// Moves a dragged tab to where it was dropped (spec §3.2).
    public func moveTab(_ id: Tab.ID, to destination: TabDestination) {
        perform { try $0.moveTab(id, to: destination) }
    }

    /// Moves a tab to another space, into the same kind of section.
    public func moveTab(_ id: Tab.ID, toSpace spaceID: Space.ID) {
        perform { try $0.moveTab(id, toSpace: spaceID) }
    }

    /// Moves a tab into Essentials, at the end.
    public func addToEssentials(_ id: Tab.ID) {
        perform { try $0.addToEssentials(id) }
    }

    /// Moves a tab out of Essentials, to the top of the current space's regular tabs.
    public func removeFromEssentials(_ id: Tab.ID) {
        perform { try $0.removeFromEssentials(id, to: $0.currentSpaceID) }
    }

    /// Copies a tab right after the original.
    public func duplicateTab(_ id: Tab.ID) {
        let time = now
        perform { try $0.duplicateTab(id, now: time) }
    }

    /// Renames a folder. Does nothing when `name` is blank.
    public func renameFolder(_ id: Folder.ID, to name: String) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        perform { try $0.renameFolder(id, to: name) }
    }

    /// Deletes a folder. Its tabs and folders take its place.
    public func deleteFolder(_ id: Folder.ID) {
        perform { try $0.deleteFolder(id) }
    }
}
