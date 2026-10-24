import Testing

@testable import ZenState

@Suite struct SpacePagingTests {
    @Test func restingOnAPage() {
        let paging = SpacePaging(offset: 390, pageWidth: 390, pageCount: 3)
        #expect(paging.from == 1)
        #expect(paging.to == 2)
        #expect(paging.fraction == 0)
        #expect(paging.nearestIndex == 1)
    }

    @Test func betweenTwoPages() {
        let paging = SpacePaging(offset: 300, pageWidth: 400, pageCount: 3)
        #expect(paging.from == 0)
        #expect(paging.to == 1)
        #expect(paging.fraction == 0.75)
        #expect(paging.nearestIndex == 1)
    }

    @Test func rubberBandIsClamped() {
        let before = SpacePaging(offset: -80, pageWidth: 400, pageCount: 3)
        #expect(before.from == 0)
        #expect(before.fraction == 0)
        let after = SpacePaging(offset: 900, pageWidth: 400, pageCount: 3)
        #expect(after.from == 2)
        #expect(after.to == 2)
        #expect(after.fraction == 0)
    }

    @Test func degenerateSizes() {
        let noWidth = SpacePaging(offset: 100, pageWidth: 0, pageCount: 3)
        #expect(noWidth.from == 0)
        #expect(noWidth.fraction == 0)
        let onePage = SpacePaging(offset: 100, pageWidth: 400, pageCount: 1)
        #expect(onePage.from == 0)
        #expect(onePage.to == 0)
        #expect(onePage.fraction == 0)
    }
}
