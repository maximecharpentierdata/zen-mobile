import ZenModel

/// One visible row of a space's pinned section, flattened from the folder tree so lists stay simple
/// (spec §3.2). Children of collapsed folders are not included.
public enum PinnedRow: Hashable, Identifiable, Sendable {
    /// A folder row: the folder, its nesting depth (0 at the root) and how many tabs it holds in total.
    case folder(Folder, depth: Int, tabCount: Int)
    /// A tab row and its nesting depth.
    case tab(Tab, depth: Int)

    /// A stable identifier for list diffing.
    public var id: String {
        switch self {
        case .folder(let folder, _, _):
            "folder-\(folder.id)"
        case .tab(let tab, _):
            "tab-\(tab.id)"
        }
    }

    /// The visible rows for a pinned tree, in display order.
    public static func rows(for items: [PinnedItem], depth: Int = 0) -> [PinnedRow] {
        items.flatMap { item -> [PinnedRow] in
            switch item {
            case .tab(let tab):
                return [.tab(tab, depth: depth)]
            case .folder(let folder):
                let header = PinnedRow.folder(folder, depth: depth, tabCount: item.allTabs.count)
                guard folder.isExpanded else { return [header] }
                return [header] + rows(for: folder.children, depth: depth + 1)
            }
        }
    }

    /// Every folder of a pinned tree, collapsed or not, in display order. Used by "Move to folder".
    public static func allFolders(in items: [PinnedItem]) -> [Folder] {
        items.flatMap { item -> [Folder] in
            guard let folder = item.folder else { return [] }
            return [folder] + allFolders(in: folder.children)
        }
    }
}
