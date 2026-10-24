import Foundation
import Testing
import ZenModel

@testable import ZenState

@MainActor
@Suite struct RecentlyClosedTests {
    @Test func restoreAndAutoCloseSetting() throws {
        let state = BrowserState(data: .firstLaunch(), saveDelay: .seconds(3600))
        let tab = try #require(state.newTab())
        state.closeTab(tab)
        #expect(state.data.recentlyClosed.map(\.id) == [tab])
        state.restoreClosedTab(tab)
        #expect(state.data.recentlyClosed.isEmpty)
        #expect(state.data.currentSpace.regular.first?.id == tab)
        state.setAutoCloseDelay(.never)
        #expect(state.data.autoCloseDelay == .never)
    }
}
