import Testing

@testable import ZenState

@Suite struct BarScrollTests {
    private func makeScroll() -> BarScroll {
        BarScroll(minimizeDistance: 20, expandDistance: 30)
    }

    /// Drags the finger through `translations`, positive downwards, on a page that isn't at its top.
    private func drag(_ scroll: inout BarScroll, _ translations: [Double]) {
        scroll.dragBegan()
        for translation in translations {
            scroll.dragMoved(translation: translation, isAtTop: false, canScroll: true)
        }
    }

    @Test func startsExpanded() {
        #expect(!makeScroll().isMinimized)
    }

    @Test func scrollingDownMinimizesPastTheDistance() {
        var scroll = makeScroll()
        drag(&scroll, [-19])
        #expect(!scroll.isMinimized)
        drag(&scroll, [-20])
        #expect(scroll.isMinimized)
    }

    @Test func scrollingUpExpandsPastTheDistance() {
        var scroll = makeScroll()
        drag(&scroll, [-40])
        drag(&scroll, [29])
        #expect(scroll.isMinimized)
        drag(&scroll, [30])
        #expect(!scroll.isMinimized)
    }

    @Test func distanceCountsFromWhereTheFingerTurned() {
        var scroll = makeScroll()
        drag(&scroll, [50, 35])
        #expect(!scroll.isMinimized)
        drag(&scroll, [50, 30])
        #expect(scroll.isMinimized)
        drag(&scroll, [-10, -40, -10])
        #expect(!scroll.isMinimized)
    }

    @Test func bothDirectionsInOneDrag() {
        var scroll = makeScroll()
        drag(&scroll, [-25, 0])
        #expect(scroll.isMinimized)
        drag(&scroll, [-25, 5])
        #expect(!scroll.isMinimized)
    }

    @Test func topOfThePageKeepsTheBarExpanded() {
        var scroll = makeScroll()
        drag(&scroll, [-40])
        scroll.dragMoved(translation: -60, isAtTop: true, canScroll: true)
        #expect(!scroll.isMinimized)
    }

    @Test func pageThatFitsKeepsTheBarExpanded() {
        var scroll = makeScroll()
        scroll.dragBegan()
        scroll.dragMoved(translation: -40, isAtTop: false, canScroll: false)
        #expect(!scroll.isMinimized)
    }

    @Test func expandRestoresTheBar() {
        var scroll = makeScroll()
        drag(&scroll, [-40])
        scroll.expand()
        #expect(!scroll.isMinimized)
    }
}
