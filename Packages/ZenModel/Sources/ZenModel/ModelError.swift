/// Why a model operation was refused.
public enum ModelError: Error, Equatable, Sendable {
    /// No space has this identifier.
    case spaceNotFound(Space.ID)
    /// No tab has this identifier.
    case tabNotFound(Tab.ID)
    /// No folder has this identifier.
    case folderNotFound(Folder.ID)
    /// The last space can't be deleted (spec §2).
    case cannotDeleteLastSpace
    /// A folder can't be moved into itself or into one of its own descendants.
    case folderCycle
    /// The operation doesn't apply where the tab currently is, for example pinning a tab that is already pinned.
    case invalidTabLocation(Tab.ID)
}
