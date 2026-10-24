/// Where a tab lives. A tab is in exactly one place (spec §2).
public enum TabLocation: Hashable, Sendable {
    /// In the shared Essentials grid.
    case essentials
    /// In a space's pinned section, at the root or inside a folder.
    case pinned(Space.ID, folder: Folder.ID?)
    /// In a space's regular tabs.
    case regular(Space.ID)
}
