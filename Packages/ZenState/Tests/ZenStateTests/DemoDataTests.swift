import Foundation
import Testing
import ZenModel

@testable import ZenState

@Suite struct DemoDataTests {
    @Test func demoDataMatchesDesign1A() {
        let data = DemoData.browserData(now: Date(timeIntervalSince1970: 0))
        #expect(data.spaces.map(\.name) == ["Personal", "Work", "Research"])
        #expect(data.essentials.count == 4)
        #expect(data.currentSpace.pinned.first?.folder?.children.count == 2)
        #expect(data.currentSpace.regular.first?.title == "Weekend weather")
    }
}
