import Foundation

/// Everything the browser keeps between launches: spaces, Essentials and recently closed tabs (spec §2).
public struct BrowserData: Hashable, Codable, Sendable {
    /// The maximum number of tabs kept in ``recentlyClosed``.
    public static let recentlyClosedLimit = 50

    /// The spaces in the user's order. Never empty.
    public private(set) var spaces: [Space]
    /// The space shown on launch and on the space screen.
    public private(set) var currentSpaceID: Space.ID
    /// Favourite sites, shared by all spaces (spec §2).
    public internal(set) var essentials: [Tab]
    /// Closed tabs, most recent first, so they can be restored (spec §3.2).
    public internal(set) var recentlyClosed: [Tab]
    /// The delay after which unopened regular tabs are closed (spec §3.2).
    public var autoCloseDelay: AutoCloseDelay

    /// The data for a first launch: one empty space called "Personal" (spec §3.1).
    public static func firstLaunch() -> BrowserData {
        let personal = Space(name: "Personal", icon: "P", accentColor: 0x9B8CFF)
        return BrowserData(spaces: [personal], currentSpaceID: personal.id)
    }

    init(spaces: [Space], currentSpaceID: Space.ID) {
        precondition(!spaces.isEmpty, "BrowserData needs at least one space")
        self.spaces = spaces
        self.currentSpaceID = currentSpaceID
        self.essentials = []
        self.recentlyClosed = []
        self.autoCloseDelay = .oneDay
    }

    /// The space with this id, if any.
    public func space(_ id: Space.ID) -> Space? {
        spaces.first { $0.id == id }
    }

    /// The space currently shown.
    public var currentSpace: Space {
        space(currentSpaceID) ?? spaces[0]
    }

    func spaceIndex(_ id: Space.ID) throws -> Int {
        guard let index = spaces.firstIndex(where: { $0.id == id }) else { throw ModelError.spaceNotFound(id) }
        return index
    }

    /// Applies `change` to a copy of the space and keeps it only if `change` doesn't throw,
    /// so a refused operation never leaves a space half-changed.
    mutating func updateSpace(_ id: Space.ID, _ change: (inout Space) throws -> Void) throws {
        let index = try spaceIndex(id)
        var space = spaces[index]
        try change(&space)
        spaces[index] = space
    }

    mutating func setSpaces(_ newSpaces: [Space], current: Space.ID) {
        precondition(!newSpaces.isEmpty, "BrowserData needs at least one space")
        spaces = newSpaces
        currentSpaceID = newSpaces.contains { $0.id == current } ? current : newSpaces[0].id
    }
}
