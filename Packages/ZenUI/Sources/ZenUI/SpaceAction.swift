import ZenModel

/// What the space header's options menu asks for (spec §3.2, §3.7).
enum SpaceAction: Equatable {
    case edit(Space.ID)
    /// Moves the space one place left (`step` -1) or right (`step` 1).
    case move(Space.ID, step: Int)
    case newFolder(Space.ID)
    case delete(Space.ID)
    case newSpace
    case recentlyClosed
    case setAutoCloseDelay(AutoCloseDelay)
}
