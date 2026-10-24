import CoreGraphics

/// Gesture thresholds. Every value marked *(tune)* in `docs/product-spec.md` lives here and only here.
enum GestureMetrics {
    /// Upward drag on the page bar after which releasing goes back to the space (spec §3.5).
    static let barStopSpace: CGFloat = 120
    /// Upward drag on the page bar after which releasing opens a new tab (spec §3.5).
    static let barStopNewTab: CGFloat = 280
    /// Share of the screen width past which releasing a horizontal swipe changes space (spec §3.3).
    static let spaceSwipeCommitFraction: CGFloat = 0.5
    /// Movement after which a drag locks to horizontal or vertical (spec §3.3).
    static let directionLockDistance: CGFloat = 10
}
