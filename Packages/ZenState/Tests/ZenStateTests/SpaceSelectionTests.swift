import Foundation
import Testing
import ZenModel

@testable import ZenState

@MainActor
@Suite struct SpaceSelectionTests {
    private func makeState() -> (BrowserState, [Space.ID]) {
        var data = BrowserData.firstLaunch()
        let first = data.currentSpaceID
        let second = data.addSpace(name: "Work", icon: "W", accentColor: 0xF0A060)
        let third = data.addSpace(name: "Research", icon: "R", accentColor: 0x5CC8BE)
        return (BrowserState(data: data, saveDelay: .seconds(3600)), [first, second, third])
    }

    @Test func stepsForwardAndBack() {
        let (state, ids) = makeState()
        state.selectSpace(step: 1)
        #expect(state.data.currentSpaceID == ids[1])
        state.selectSpace(step: 1)
        #expect(state.data.currentSpaceID == ids[2])
        state.selectSpace(step: -2)
        #expect(state.data.currentSpaceID == ids[0])
    }

    @Test func stopsAtTheEnds() {
        let (state, ids) = makeState()
        state.selectSpace(step: -1)
        #expect(state.data.currentSpaceID == ids[0])
        state.selectSpace(step: 2)
        state.selectSpace(step: 1)
        #expect(state.data.currentSpaceID == ids[2])
    }
}
