/// Decides when the page bar minimizes while the page scrolls (spec §3.4). Pure, so the thresholds can be tested.
///
/// It follows the finger rather than the page's scroll position, because the scroll position can also move without
/// the finger, for example when the page is resized as the bar changes, and that must not flip the bar back.
public struct BarScroll: Sendable, Equatable {
    /// Upward finger travel, in points, after which the bar minimizes.
    public let minimizeDistance: Double
    /// Downward finger travel, in points, after which a minimized bar expands again.
    public let expandDistance: Double
    /// Whether the bar is minimized.
    public private(set) var isMinimized = false
    /// The finger's position, in the current drag, where it last turned against the bar's state.
    private var turn: Double = 0

    /// Creates an expanded bar with its thresholds, which come from the UI's gesture metrics.
    public init(minimizeDistance: Double, expandDistance: Double) {
        self.minimizeDistance = minimizeDistance
        self.expandDistance = expandDistance
    }

    /// A drag on the page started.
    public mutating func dragBegan() {
        turn = 0
    }

    /// The finger moved. `translation` is its travel since the drag began, in points, positive downwards.
    /// At the top of the page, or on a page that fits the screen, the bar stays expanded.
    public mutating func dragMoved(translation: Double, isAtTop: Bool, canScroll: Bool) {
        if isAtTop || !canScroll {
            change(minimized: false, at: translation)
        } else if isMinimized {
            turn = min(turn, translation)
            if translation - turn >= expandDistance { change(minimized: false, at: translation) }
        } else {
            turn = max(turn, translation)
            if turn - translation >= minimizeDistance { change(minimized: true, at: translation) }
        }
    }

    /// Expands the bar, for example when it is tapped or a new page loads.
    public mutating func expand() {
        isMinimized = false
    }

    private mutating func change(minimized: Bool, at translation: Double) {
        isMinimized = minimized
        turn = translation
    }
}
