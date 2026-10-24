import CoreGraphics
import ZenState

/// Gesture thresholds. Every value marked *(tune)* in `docs/product-spec.md` lives here and only here.
enum GestureMetrics {
    /// Upward drag on the page bar after which releasing goes back to the space (spec §3.5).
    static let barStopSpace: CGFloat = 120
    /// Upward drag on the page bar after which releasing opens a new tab (spec §3.5).
    static let barStopNewTab: CGFloat = 420
    /// Upward speed, in points per second, from which a release goes back to the space, at any distance (spec §3.5).
    static let barFlickVelocity: CGFloat = 800
    /// Movement before a touch on the page bar becomes a drag rather than a tap.
    static let barDragMinimumDistance: CGFloat = 10
    /// How far towards its row the page shrinks while dragging, at stop 2 (0 = not at all, 1 = onto the row).
    static let barMaxDragCollapse: CGFloat = 0.6
    /// Upward finger travel on a page after which the page bar minimizes (spec §3.4).
    static let barMinimizeDistance: CGFloat = 24
    /// Downward finger travel on a page after which the minimized page bar expands again (spec §3.4).
    static let barExpandDistance: CGFloat = 24
    /// Sideways swipe on a page after which releasing goes back or forward (spec §3.4).
    static let pageSwipeCommitDistance: CGFloat = 100
    /// Sideways speed, in points per second, from which a shorter swipe on a page still navigates (spec §3.4).
    static let pageSwipeFlickVelocity: CGFloat = 800
}

extension GestureMetrics {
    /// The bar gesture's decision logic, with these thresholds.
    static var barGesture: BarGesture {
        BarGesture(stopSpace: barStopSpace, stopNewTab: barStopNewTab, flickVelocity: barFlickVelocity)
    }

    /// When the page bar minimizes while the page scrolls, with these thresholds.
    static var barScroll: BarScroll {
        BarScroll(minimizeDistance: barMinimizeDistance, expandDistance: barExpandDistance)
    }

    /// The page swipe's decision logic, with these thresholds.
    static var pageSwipe: PageSwipe {
        PageSwipe(commitDistance: pageSwipeCommitDistance, flickVelocity: pageSwipeFlickVelocity)
    }
}
