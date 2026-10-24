/// Where the space pager is between two spaces, from its scroll position (spec §3.3; design 2A).
///
/// The interface uses it to blend the two spaces' colours while the list follows the finger.
public struct SpacePaging: Equatable, Sendable {
    /// The index of the space on the left of the current position.
    public let from: Int
    /// The index of the space on the right, or `from` at the last space.
    public let to: Int
    /// How far the position is from `from` to `to`, between 0 and 1.
    public let fraction: Double

    /// The paging state for a horizontal `offset` in a pager of `pageCount` pages that are `pageWidth` wide.
    /// Positions before the first page or after the last one (the rubber band) are clamped.
    public init(offset: Double, pageWidth: Double, pageCount: Int) {
        let lastIndex = max(pageCount - 1, 0)
        let position = pageWidth > 0 ? min(max(offset / pageWidth, 0), Double(lastIndex)) : 0
        let from = min(Int(position.rounded(.down)), lastIndex)
        self.from = from
        self.to = min(from + 1, lastIndex)
        self.fraction = from == to ? 0 : position - Double(from)
    }

    /// The index of the space that is mostly on screen.
    public var nearestIndex: Int {
        fraction < 0.5 ? from : to
    }
}
