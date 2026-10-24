import Testing

@testable import ZenModel

@Suite struct DuplicateTests {
    @Test func duplicateRegularTabGoesRightAfterIt() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let second = try data.newTab(url: Fixtures.url("b"), in: space, now: Fixtures.now)
        let first = try data.newTab(url: Fixtures.url("a"), in: space, now: Fixtures.now)
        let copy = try data.duplicateTab(first, now: Fixtures.now)
        #expect(data.currentSpace.regular.map(\.id) == [first, copy, second])
        #expect(data.tab(copy)?.url == Fixtures.url("a"))
        #expect(copy != first)
    }

    @Test func duplicatePinnedTabStaysInItsFolderAndKeepsItsPinnedURL() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let folder = try data.createFolder(named: "Reading", in: space)
        let tab = try data.newTab(url: Fixtures.url("a"), in: space, now: Fixtures.now)
        try data.pin(tab, into: folder)
        let copy = try data.duplicateTab(tab, now: Fixtures.now)
        #expect(data.location(of: copy) == .pinned(space, folder: folder))
        #expect(data.tab(copy)?.pinnedURL == Fixtures.url("a"))
        #expect(data.currentSpace.pinned.first?.folder?.children.compactMap(\.tab?.id) == [tab, copy])
    }

    @Test func duplicateEssential() throws {
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(url: Fixtures.url("a"), in: data.currentSpaceID, now: Fixtures.now)
        try data.addToEssentials(tab)
        let copy = try data.duplicateTab(tab, now: Fixtures.now)
        #expect(data.essentials.map(\.id) == [tab, copy])
    }

    @Test func duplicateUnknownTabThrows() {
        var data = BrowserData.firstLaunch()
        let unknown = Tab.ID()
        #expect(throws: ModelError.tabNotFound(unknown)) { try data.duplicateTab(unknown, now: Fixtures.now) }
    }
}
