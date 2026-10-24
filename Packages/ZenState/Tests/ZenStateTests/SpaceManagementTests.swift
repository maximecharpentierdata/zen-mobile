import Foundation
import Testing
import ZenModel

@testable import ZenState

@MainActor
@Suite struct SpaceManagementTests {
    private func makeState() -> BrowserState {
        BrowserState(data: .firstLaunch(), saveDelay: .seconds(3600))
    }

    @Test func formTrimsAndDefaultsTheIcon() {
        #expect(SpaceForm(name: "  work ", icon: " ") == SpaceForm(name: "work", icon: "W"))
        #expect(SpaceForm(name: "work", icon: " 💼 ")?.icon == "💼")
        #expect(SpaceForm(name: "work", icon: "")?.icon == "W")
        #expect(SpaceForm(name: "   ", icon: "W") == nil)
    }

    @Test func createSpaceAddsItLastAndShowsIt() throws {
        let state = makeState()
        let id = try #require(state.createSpace(name: "Work", icon: "", accentColor: 0xF0A060))
        #expect(state.data.spaces.last?.id == id)
        #expect(state.data.currentSpaceID == id)
        #expect(state.data.currentSpace.icon == "W")
        #expect(state.createSpace(name: " ", icon: "", accentColor: 0) == nil)
        #expect(state.data.spaces.count == 2)
    }

    @Test func editSpaceKeepsTheOldValuesWhenTheNameIsBlank() {
        let state = makeState()
        let id = state.data.currentSpaceID
        state.editSpace(id, name: "Home", icon: "🏠", accentColor: 0x5CC8BE)
        #expect(state.data.currentSpace.name == "Home")
        #expect(state.data.currentSpace.accentColor == 0x5CC8BE)
        state.editSpace(id, name: "", icon: "X", accentColor: 0)
        #expect(state.data.currentSpace.name == "Home")
        #expect(state.data.currentSpace.icon == "🏠")
    }

    @Test func moveSpaceStaysInBounds() throws {
        let state = makeState()
        let first = state.data.currentSpaceID
        let second = try #require(state.createSpace(name: "Work", icon: "", accentColor: 0))
        #expect(state.canMoveSpace(second, step: -1))
        #expect(!state.canMoveSpace(second, step: 1))
        state.moveSpace(second, step: -1)
        #expect(state.data.spaces.map(\.id) == [second, first])
        state.moveSpace(second, step: -1)
        #expect(state.data.spaces.map(\.id) == [second, first])
    }

    @Test func deleteSpaceCanMoveItsTabs() throws {
        let state = makeState()
        let first = state.data.currentSpaceID
        let second = try #require(state.createSpace(name: "Work", icon: "", accentColor: 0))
        let tab = try #require(state.newTab())
        state.deleteSpace(second, tabs: .moveTo(first))
        #expect(state.data.spaces.map(\.id) == [first])
        #expect(state.data.location(of: tab) == .regular(first))
        state.deleteSpace(first, tabs: .close)
        #expect(state.data.spaces.count == 1)
    }
}
