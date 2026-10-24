import Testing

@testable import ZenState

@Suite struct BarGestureTests {
    private let gesture = BarGesture(stopSpace: 120, stopNewTab: 280, flickVelocity: 800)

    @Test func stagesFollowTheStops() {
        #expect(gesture.stage(upwardDistance: 0) == .stay)
        #expect(gesture.stage(upwardDistance: 119) == .stay)
        #expect(gesture.stage(upwardDistance: 120) == .showSpace)
        #expect(gesture.stage(upwardDistance: 279) == .showSpace)
        #expect(gesture.stage(upwardDistance: 280) == .newTab)
    }

    @Test func downwardDragStays() {
        #expect(gesture.outcome(upwardDistance: -50, upwardVelocity: -300) == .stay)
    }

    @Test func fastFlickBeforeStopOneGoesToSpace() {
        #expect(gesture.outcome(upwardDistance: 40, upwardVelocity: 900) == .showSpace)
        #expect(gesture.outcome(upwardDistance: 40, upwardVelocity: 300) == .stay)
    }

    @Test func flickNeverSkipsToNewTab() {
        #expect(gesture.outcome(upwardDistance: 200, upwardVelocity: 5000) == .showSpace)
        #expect(gesture.outcome(upwardDistance: 300, upwardVelocity: 0) == .newTab)
    }

    @Test func shrinkIsClamped() {
        #expect(gesture.shrink(upwardDistance: -10) == 0)
        #expect(gesture.shrink(upwardDistance: 140) == 0.5)
        #expect(gesture.shrink(upwardDistance: 999) == 1)
    }
}
