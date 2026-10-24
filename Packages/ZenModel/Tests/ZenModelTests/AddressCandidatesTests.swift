import Foundation
import Testing

@testable import ZenModel

@Suite struct AddressCandidatesTests {
    @Test func candidatesStartWithEssentialsAndTheCurrentSpace() throws {
        var spaces = Fixtures.twoSpaces()
        let work = try spaces.data.newTab(url: Fixtures.url("work"), in: spaces.work, now: Fixtures.now)
        let regular = try spaces.data.newTab(url: Fixtures.url("regular"), in: spaces.personal, now: Fixtures.now)
        let pinned = try spaces.data.newTab(url: Fixtures.url("pinned"), in: spaces.personal, now: Fixtures.now)
        try spaces.data.pin(pinned)
        let essential = try spaces.data.newTab(url: Fixtures.url("essential"), in: spaces.personal, now: Fixtures.now)
        try spaces.data.addToEssentials(essential)
        let closed = try spaces.data.newTab(url: Fixtures.url("closed"), in: spaces.personal, now: Fixtures.now)
        try spaces.data.closeTab(closed)

        #expect(spaces.data.addressCandidates.map(\.id) == [essential, pinned, regular, work, closed])
    }

    @Test func tabsWithoutAnAddressAreLeftOut() throws {
        var data = BrowserData.firstLaunch()
        _ = try data.newTab(in: data.currentSpaceID, now: Fixtures.now)
        #expect(data.addressCandidates.isEmpty)
    }
}
