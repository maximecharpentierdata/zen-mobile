import ZenModel

/// What the space header's options menu asks for (spec §3.2, §3.7).
enum SpaceAction: Equatable {
    case edit(Space.ID)
    case moveLeft(Space.ID)
    case moveRight(Space.ID)
    case delete(Space.ID)
    case newSpace
    case recentlyClosed
    case setAutoCloseDelay(AutoCloseDelay)
}
