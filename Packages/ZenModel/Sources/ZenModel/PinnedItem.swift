/// One entry of a space's pinned section: a tab or a folder.
public enum PinnedItem: Hashable, Codable, Sendable {
    /// A pinned tab.
    case tab(Tab)
    /// A folder, which can hold tabs and other folders.
    case folder(Folder)

    /// The tab, if this item is one.
    public var tab: Tab? {
        if case .tab(let tab) = self { return tab }
        return nil
    }

    /// The folder, if this item is one.
    public var folder: Folder? {
        if case .folder(let folder) = self { return folder }
        return nil
    }

    /// Every tab in this item, including those inside nested folders, in display order.
    public var allTabs: [Tab] {
        switch self {
        case .tab(let tab): [tab]
        case .folder(let folder): folder.children.flatMap(\.allTabs)
        }
    }
}
