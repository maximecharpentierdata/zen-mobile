import Testing

@testable import ZenModel

@Suite struct SpacesTests {
    @Test func firstLaunchHasOneEmptyPersonalSpace() {
        let data = BrowserData.firstLaunch()
        #expect(data.spaces.map(\.name) == ["Personal"])
        #expect(data.currentSpace.regular.isEmpty)
        #expect(data.currentSpace.pinned.isEmpty)
        #expect(data.essentials.isEmpty)
        #expect(data.autoCloseDelay == .oneDay)
    }

    @Test func addSpaceAppendsWithoutChangingCurrent() {
        let fixture = Fixtures.twoSpaces()
        let data = fixture.data
        let personal = fixture.personal
        let work = fixture.work
        #expect(data.spaces.map(\.id) == [personal, work])
        #expect(data.currentSpaceID == personal)
    }

    @Test func selectSpaceChangesCurrent() throws {
        let fixture = Fixtures.twoSpaces()
        var data = fixture.data
        let work = fixture.work
        try data.selectSpace(work)
        #expect(data.currentSpaceID == work)
    }

    @Test func selectUnknownSpaceThrows() {
        var data = BrowserData.firstLaunch()
        let unknown = Space.ID()
        #expect(throws: ModelError.spaceNotFound(unknown)) { try data.selectSpace(unknown) }
    }

    @Test func editSpaceChangesNameIconAndColour() throws {
        var data = BrowserData.firstLaunch()
        try data.editSpace(data.currentSpaceID, name: "Home", icon: "H", accentColor: 0x5CC8BE)
        #expect(data.currentSpace.name == "Home")
        #expect(data.currentSpace.icon == "H")
        #expect(data.currentSpace.accentColor == 0x5CC8BE)
    }

    @Test func moveSpaceReordersAndClampsIndex() throws {
        let fixture = Fixtures.twoSpaces()
        var data = fixture.data
        let personal = fixture.personal
        let work = fixture.work
        try data.moveSpace(work, to: -5)
        #expect(data.spaces.map(\.id) == [work, personal])
        try data.moveSpace(work, to: 99)
        #expect(data.spaces.map(\.id) == [personal, work])
    }

    @Test func lastSpaceCannotBeDeleted() {
        var data = BrowserData.firstLaunch()
        #expect(throws: ModelError.cannotDeleteLastSpace) {
            try data.deleteSpace(data.currentSpaceID, tabs: .close)
        }
    }

    @Test func deletingSpaceWithCloseSendsTabsToRecentlyClosed() throws {
        let fixture = Fixtures.twoSpaces()
        var data = fixture.data
        let personal = fixture.personal
        let work = fixture.work
        let tab = try data.newTab(url: Fixtures.url("a"), in: work, now: Fixtures.now)
        try data.deleteSpace(work, tabs: .close)
        #expect(data.spaces.map(\.id) == [personal])
        #expect(data.recentlyClosed.map(\.id) == [tab])
    }

    @Test func deletingSpaceWithMoveKeepsTabs() throws {
        let fixture = Fixtures.twoSpaces()
        var data = fixture.data
        let personal = fixture.personal
        let work = fixture.work
        let tab = try data.newTab(in: work, now: Fixtures.now)
        try data.deleteSpace(work, tabs: .moveTo(personal))
        #expect(data.space(personal)?.regular.map(\.id) == [tab])
        #expect(data.recentlyClosed.isEmpty)
    }

    @Test func deletingCurrentSpaceSelectsThePreviousOne() throws {
        let fixture = Fixtures.twoSpaces()
        var data = fixture.data
        let personal = fixture.personal
        let work = fixture.work
        try data.selectSpace(work)
        try data.deleteSpace(work, tabs: .close)
        #expect(data.currentSpaceID == personal)
    }

    @Test func deletingSpaceIntoItselfThrowsAndChangesNothing() throws {
        let fixture = Fixtures.twoSpaces()
        var data = fixture.data
        let work = fixture.work
        let before = data
        #expect(throws: ModelError.spaceNotFound(work)) { try data.deleteSpace(work, tabs: .moveTo(work)) }
        #expect(data == before)
    }
}
