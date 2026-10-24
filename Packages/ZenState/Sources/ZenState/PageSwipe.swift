/// Decides what a sideways swipe on an open page does (spec §3.4). Pure, so the thresholds can be tested.
///
/// The finger moving right goes back in the page's history; moving left goes forward, as in Safari.
public struct PageSwipe: Sendable {
    /// Where releasing the swipe would lead.
    public enum Outcome: Sendable, Equatable {
        /// The page stays where it is.
        case stay
        /// The previous page in the tab's history.
        case back
        /// The next page in the tab's history.
        case forward
    }

    /// Sideways distance, in points, from which releasing navigates.
    public let commitDistance: Double
    /// Sideways speed, in points per second, from which a shorter swipe still navigates.
    public let flickVelocity: Double

    /// Creates a swipe with its thresholds, which come from the UI's gesture metrics.
    public init(commitDistance: Double, flickVelocity: Double) {
        self.commitDistance = commitDistance
        self.flickVelocity = flickVelocity
    }

    /// The direction a sideways movement points to, if the history allows going there.
    /// `translation` is positive when the finger moves right.
    public func direction(translation: Double, canGoBack: Bool, canGoForward: Bool) -> Outcome {
        if translation > 0, canGoBack { return .back }
        if translation < 0, canGoForward { return .forward }
        return .stay
    }

    /// What a release does: navigate when the swipe went far or fast enough in an allowed direction.
    /// A flick against the direction of the movement cancels it.
    public func outcome(
        translation: Double, velocity: Double, canGoBack: Bool, canGoForward: Bool
    ) -> Outcome {
        let heading = direction(translation: translation, canGoBack: canGoBack, canGoForward: canGoForward)
        guard heading != .stay, translation * velocity >= 0 else { return .stay }
        if abs(translation) >= commitDistance || abs(velocity) >= flickVelocity { return heading }
        return .stay
    }

    /// How far the page follows the finger: fully towards an allowed direction, not at all otherwise.
    public func offset(translation: Double, canGoBack: Bool, canGoForward: Bool) -> Double {
        let heading = direction(translation: translation, canGoBack: canGoBack, canGoForward: canGoForward)
        if heading == .stay { return 0 }
        return translation
    }
}
