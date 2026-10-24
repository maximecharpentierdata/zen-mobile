import CoreGraphics
import ZenState

/// Gesture thresholds. Every value marked *(tune)* in `docs/product-spec.md` lives here and only here.
enum GestureMetrics {
    /// Upward drag on the page bar after which releasing goes back to the space (spec §3.5).
    static let barStopSpace: CGFloat = 120
    /// Upward drag on the page bar after which releasing opens a new tab (spec §3.5).
    static let barStopNewTab: CGFloat = 280
    /// Upward speed, in points per second, from which a release before stop 2 goes back to the space (spec §3.5).
    static let barFlickVelocity: CGFloat = 800
    /// Movement before a touch on the page bar becomes a drag rather than a tap.
    static let barDragMinimumDistance: CGFloat = 10
    /// How far towards its row the page shrinks while dragging, at stop 2 (0 = not at all, 1 = onto the row).
    static let barMaxDragCollapse: CGFloat = 0.6
}

extension GestureMetrics {
    /// The bar gesture's decision logic, with these thresholds.
    static var barGesture: BarGesture {
        BarGesture(stopSpace: barStopSpace, stopNewTab: barStopNewTab, flickVelocity: barFlickVelocity)
    }
}
