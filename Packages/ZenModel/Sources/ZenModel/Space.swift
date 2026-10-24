/// A named group of tabs with its own icon and colour (spec §2).
public struct Space: Identifiable, Hashable, Codable, Sendable {
    /// A space's identifier.
    public typealias ID = Identifier<Space>

    /// The space's stable identifier.
    public let id: ID
    /// The name shown in the header.
    public var name: String
    /// A short icon, such as an emoji or a letter.
    public var icon: String
    /// The accent colour as a 24-bit RGB value, for example `0x9B8CFF`.
    public var accentColor: UInt32
    /// Tabs and folders above the divider, in the user's order.
    public var pinned: [PinnedItem]
    /// Tabs below the divider, in the user's order. New tabs go first (spec §3.5).
    public var regular: [Tab]

    /// Creates a space.
    public init(
        id: ID = ID(),
        name: String,
        icon: String,
        accentColor: UInt32,
        pinned: [PinnedItem] = [],
        regular: [Tab] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.accentColor = accentColor
        self.pinned = pinned
        self.regular = regular
    }
}
