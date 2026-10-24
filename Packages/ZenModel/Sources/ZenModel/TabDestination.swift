/// Where a dragged tab is dropped (spec §3.2). Each index is a position in the destination list as it is shown
/// before the move, so "before the row at `index`".
public enum TabDestination: Hashable, Sendable {
    /// Into Essentials.
    case essentials(index: Int)
    /// Into a space's pinned section, in `folder` (the root when `nil`).
    case pinned(Space.ID, folder: Folder.ID?, index: Int)
    /// Into a space's regular tabs.
    case regular(Space.ID, index: Int)
}

extension TabDestination {
    /// The position in the destination list.
    var index: Int {
        switch self {
        case .essentials(let index), .pinned(_, _, let index), .regular(_, let index):
            index
        }
    }
}
