import CoreGraphics

/// A step of a sideways swipe on a web page, as reported by ``WebPage`` (spec §3.4).
public enum PageSwipeEvent: Sendable {
    /// The finger moved. `translation` is in points, positive when the finger moves right.
    case changed(translation: CGFloat)
    /// The finger lifted, or the swipe was cancelled (then both values are 0). `velocity` is in points per second.
    case ended(translation: CGFloat, velocity: CGFloat)
}
