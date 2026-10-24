import Testing

@testable import ZenModel

@Suite struct OrganizeTests {
    @Test func pinMovesTabAndRemembersURL() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let tab = try data.newTab(url: Fixtures.url("mail"), in: space, now: Fixtures.now)
        try data.pin(tab)
        #expect(data.location(of: tab) == .pinned(space, folder: nil))
        #expect(data.tab(tab)?.pinnedURL == Fixtures.url("mail"))
        #expect(data.currentSpace.regular.isEmpty)
    }

    @Test func pinIntoFolder() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let folder = try data.createFolder(named: "Reading", in: space)
        let tab = try data.newTab(in: space, now: Fixtures.now)
        try data.pin(tab, into: folder, at: 0)
        #expect(data.location(of: tab) == .pinned(space, folder: folder))
    }

    @Test func pinIntoUnknownFolderThrowsAndKeepsTab() throws {
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(in: data.currentSpaceID, now: Fixtures.now)
        let unknown = Folder.ID()
        #expect(throws: ModelError.folderNotFound(unknown)) { try data.pin(tab, into: unknown) }
        #expect(data.location(of: tab) == .regular(data.currentSpaceID))
    }

    @Test func pinningTwiceThrows() throws {
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(in: data.currentSpaceID, now: Fixtures.now)
        try data.pin(tab)
        #expect(throws: ModelError.invalidTabLocation(tab)) { try data.pin(tab) }
    }

    @Test func unpinMovesTabFirstAndForgetsURL() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let other = try data.newTab(in: space, now: Fixtures.now)
        let tab = try data.newTab(url: Fixtures.url("x"), in: space, now: Fixtures.now)
        try data.pin(tab)
        try data.unpin(tab)
        #expect(data.currentSpace.regular.map(\.id) == [tab, other])
        #expect(data.tab(tab)?.pinnedURL == nil)
    }

    @Test func essentialsAreSharedAndReorderable() throws {
        var (data, personal, work) = Fixtures.twoSpaces()
        let first = try data.newTab(in: personal, now: Fixtures.now)
        let second = try data.newTab(in: work, now: Fixtures.now)
        try data.addToEssentials(first)
        try data.addToEssentials(second)
        #expect(data.essentials.map(\.id) == [first, second])
        try data.moveEssential(second, to: 0)
        #expect(data.essentials.map(\.id) == [second, first])
        try data.removeFromEssentials(second, to: work)
        #expect(data.location(of: second) == .regular(work))
    }

    @Test func moveRegularTabClampsIndex() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let first = try data.newTab(in: space, now: Fixtures.now)
        let second = try data.newTab(in: space, now: Fixtures.now)
        try data.moveRegularTab(second, to: 99)
        #expect(data.currentSpace.regular.map(\.id) == [first, second])
    }

    @Test func movePinnedTabBetweenFolders() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let folder = try data.createFolder(named: "Trips", in: space)
        let tab = try data.newTab(in: space, now: Fixtures.now)
        try data.pin(tab)
        try data.movePinnedTab(tab, into: folder, at: 0)
        #expect(data.location(of: tab) == .pinned(space, folder: folder))
        try data.movePinnedTab(tab, into: nil, at: 0)
        #expect(data.location(of: tab) == .pinned(space, folder: nil))
    }

    @Test func moveTabToSpaceKeepsSectionKind() throws {
        var (data, personal, work) = Fixtures.twoSpaces()
        let regular = try data.newTab(in: personal, now: Fixtures.now)
        let pinned = try data.newTab(in: personal, now: Fixtures.now)
        try data.pin(pinned)
        try data.moveTab(regular, toSpace: work)
        try data.moveTab(pinned, toSpace: work)
        #expect(data.location(of: regular) == .regular(work))
        #expect(data.location(of: pinned) == .pinned(work, folder: nil))
    }
}
