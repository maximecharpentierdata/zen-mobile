import Foundation
import Testing
import ZenModel

@testable import ZenState

@MainActor
@Suite struct NavigationTests {
    nonisolated private static let fixedNow = Date(timeIntervalSince1970: 1_000_000)

    private func makeState() -> BrowserState {
        BrowserState(data: DemoData.browserData(now: Self.fixedNow), clock: { Self.fixedNow })
    }

    @Test func openShowsTabAndShowSpaceReturns() throws {
        let state = makeState()
        let tab = try #require(state.data.currentSpace.regular.first)
        state.open(tab.id)
        #expect(state.openTab?.id == tab.id)
        state.showSpace()
        #expect(state.openTabID == nil)
    }

    @Test func newTabOpensAddressEditing() {
        let state = makeState()
        state.startNewTab()
        #expect(state.openTab?.url == nil)
        #expect(state.isEditingAddress)
    }

    @Test func cancellingANewTabRemovesIt() {
        let state = makeState()
        let before = state.data.currentSpace.regular.count
        state.startNewTab()
        state.cancelAddressEditing()
        #expect(state.data.currentSpace.regular.count == before)
        #expect(state.openTabID == nil)
    }

    @Test func submitLoadsAddressOrSearch() throws {
        let state = makeState()
        state.startNewTab()
        state.submitAddress("example.com")
        #expect(state.openTab?.url?.absoluteString == "https://example.com")
        #expect(state.isEditingAddress == false)
        state.editAddress()
        state.submitAddress("knot tying")
        #expect(state.openTab?.url?.host() == "www.google.com")
    }

    @Test func addressOfAPinnedTabOpensANewTab() throws {
        let state = makeState()
        let tab = try #require(state.data.currentSpace.regular.first)
        let url = tab.url
        state.pin(tab.id)
        state.open(tab.id)
        state.editAddress()
        state.submitAddress("example.com")
        let newTab = try #require(state.openTab)
        #expect(newTab.id != tab.id)
        #expect(newTab.url?.absoluteString == "https://example.com")
        #expect(state.data.location(of: newTab.id) == .regular(state.data.currentSpaceID))
        #expect(state.data.tab(tab.id)?.url == url)
        #expect(state.isEditingAddress == false)
    }

    @Test func addressOfAnEssentialOpensANewTab() throws {
        let state = makeState()
        let essential = try #require(state.data.essentials.first)
        state.open(essential.id)
        state.submitAddress("example.com")
        #expect(state.openTabID != essential.id)
        #expect(state.data.tab(essential.id)?.url == essential.url)
    }

    @Test func pageChangesAreRecorded() throws {
        let state = makeState()
        let tab = try #require(state.data.currentSpace.regular.first)
        state.pageDidChange(tab.id, url: URL(string: "https://example.org"), title: "Example")
        #expect(state.data.tab(tab.id)?.title == "Example")
    }
}
