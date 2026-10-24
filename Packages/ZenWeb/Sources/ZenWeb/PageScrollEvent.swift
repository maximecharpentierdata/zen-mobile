import CoreGraphics

/// A step of a vertical drag on a web page, as reported by ``WebPage`` (spec §3.4).
public enum PageScrollEvent: Sendable {
    /// The finger touched the page and started scrolling it.
    case began
    /// The finger moved. `translation` is its travel since the drag began, in points, positive downwards.
    /// `isAtTop` tells whether the page shows its top; `canScroll` whether it is taller than the screen.
    case moved(translation: CGFloat, isAtTop: Bool, canScroll: Bool)
    /// The page reached its top, or left it, however it scrolled: by the finger, by momentum or by a tap on the
    /// status bar.
    case topChanged(isAtTop: Bool)
}
