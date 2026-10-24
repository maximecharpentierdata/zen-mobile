/// Decides what dragging the page bar up does (spec §3.5). Pure, so the thresholds can be tested.
public struct BarGesture: Sendable {
    /// Where releasing the bar would lead.
    public enum Outcome: Sendable, Equatable {
        /// Back to the open page.
        case stay
        /// Back to the space screen (stop 1).
        case showSpace
        /// A new tab with the address field (stop 2).
        case newTab
    }

    /// Upward distance, in points, of stop 1.
    public let stopSpace: Double
    /// Upward distance, in points, of stop 2.
    public let stopNewTab: Double
    /// Upward speed, in points per second, from which a release before stop 2 counts as stop 1.
    public let flickVelocity: Double

    /// Creates a gesture with its thresholds, which come from the UI's gesture metrics.
    public init(stopSpace: Double, stopNewTab: Double, flickVelocity: Double) {
        self.stopSpace = stopSpace
        self.stopNewTab = stopNewTab
        self.flickVelocity = flickVelocity
    }

    /// Where releasing now would lead, from the distance alone. Drives the stop markers and haptics.
    public func stage(upwardDistance distance: Double) -> Outcome {
        if distance >= stopNewTab { return .newTab }
        if distance >= stopSpace { return .showSpace }
        return .stay
    }

    /// What a release does: the stage, except that a fast upward flick before stop 2 goes back to the space.
    public func outcome(upwardDistance distance: Double, upwardVelocity velocity: Double) -> Outcome {
        let stage = stage(upwardDistance: distance)
        if stage == .stay, velocity >= flickVelocity { return .showSpace }
        return stage
    }

    /// How far the page has shrunk, from 0 (full screen) to 1 (at stop 2), following the finger.
    public func shrink(upwardDistance distance: Double) -> Double {
        min(max(distance / stopNewTab, 0), 1)
    }
}
