/// A named, collapsible group in a space's pinned section. Folders can be nested (spec §2).
public struct Folder: Identifiable, Hashable, Codable, Sendable {
    /// A folder's identifier.
    public typealias ID = Identifier<Folder>

    /// The folder's stable identifier.
    public let id: ID
    /// The name shown in the list.
    public var name: String
    /// Whether the folder's children are shown.
    public var isExpanded: Bool
    /// The folder's content, in the user's order.
    public var children: [PinnedItem]

    /// Creates a folder.
    public init(id: ID = ID(), name: String, isExpanded: Bool = true, children: [PinnedItem] = []) {
        self.id = id
        self.name = name
        self.isExpanded = isExpanded
        self.children = children
    }
}
