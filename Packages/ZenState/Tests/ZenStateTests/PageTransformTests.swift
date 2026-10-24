import Foundation
import Testing

@testable import ZenState

@Suite struct PageTransformTests {
    private let page = CGRect(x: 0, y: 0, width: 400, height: 800)
    private let row = CGRect(x: 20, y: 100, width: 360, height: 40)

    @Test func startIsTheFullPage() {
        let transform = PageTransform(progress: 0, page: page, row: row, rowCornerRadius: 12)
        #expect(transform.scale == 1)
        #expect(transform.offset == .zero)
        #expect(transform.maskHeight == 800)
        #expect(transform.opacity == 1)
    }

    @Test func endMatchesTheRow() {
        let transform = PageTransform(progress: 1, page: page, row: row, rowCornerRadius: 12)
        #expect(transform.scale == 0.9)
        #expect(transform.offset == CGSize(width: 0, height: -280))
        #expect(abs(transform.maskHeight * transform.scale - 40) < 0.001)
        #expect(abs(transform.cornerRadius * transform.scale - 12) < 0.001)
        #expect(transform.opacity == 0)
    }

    @Test func progressIsClamped() {
        let over = PageTransform(progress: 3, page: page, row: row, rowCornerRadius: 12)
        let end = PageTransform(progress: 1, page: page, row: row, rowCornerRadius: 12)
        #expect(over == end)
    }

    @Test func pageStaysOpaqueForMostOfTheWay() {
        let transform = PageTransform(progress: 0.5, page: page, row: row, rowCornerRadius: 12)
        #expect(transform.opacity == 1)
    }
}
