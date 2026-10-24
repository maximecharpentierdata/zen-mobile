import Testing

@testable import ZenState

@Suite struct PageSwipeTests {
    private let swipe = PageSwipe(commitDistance: 100, flickVelocity: 800)

    @Test func rightGoesBackAndLeftGoesForward() {
        #expect(swipe.outcome(translation: 150, velocity: 0, canGoBack: true, canGoForward: true) == .back)
        #expect(swipe.outcome(translation: -150, velocity: 0, canGoBack: true, canGoForward: true) == .forward)
    }

    @Test func shortSlowSwipeStays() {
        #expect(swipe.outcome(translation: 99, velocity: 300, canGoBack: true, canGoForward: true) == .stay)
        #expect(swipe.outcome(translation: 100, velocity: 0, canGoBack: true, canGoForward: true) == .back)
    }

    @Test func fastFlickNavigatesBeforeTheDistance() {
        #expect(swipe.outcome(translation: 30, velocity: 900, canGoBack: true, canGoForward: false) == .back)
        #expect(swipe.outcome(translation: -30, velocity: -900, canGoBack: false, canGoForward: true) == .forward)
    }

    @Test func flickAgainstTheMovementCancels() {
        #expect(swipe.outcome(translation: 150, velocity: -900, canGoBack: true, canGoForward: true) == .stay)
    }

    @Test func missingHistoryStays() {
        #expect(swipe.outcome(translation: 150, velocity: 900, canGoBack: false, canGoForward: true) == .stay)
        #expect(swipe.outcome(translation: -150, velocity: -900, canGoBack: true, canGoForward: false) == .stay)
    }

    @Test func pageFollowsOnlyTowardsAllowedDirection() {
        #expect(swipe.offset(translation: 60, canGoBack: true, canGoForward: false) == 60)
        #expect(swipe.offset(translation: -60, canGoBack: true, canGoForward: false) == 0)
        #expect(swipe.offset(translation: -60, canGoBack: false, canGoForward: true) == -60)
    }
}
