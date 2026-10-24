import Testing

@testable import ZenModel

@Suite struct PinnedURLTests {
    @Test func essentialsRememberTheirURLAndForgetItWhenRemoved() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let tab = try data.newTab(url: Fixtures.url("mail"), in: space, now: Fixtures.now)
        try data.addToEssentials(tab)
        #expect(data.tab(tab)?.pinnedURL == Fixtures.url("mail"))
        try data.removeFromEssentials(tab, to: space)
        #expect(data.tab(tab)?.pinnedURL == nil)
    }

    @Test func droppingIntoEssentialsRemembersTheURL() throws {
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(url: Fixtures.url("mail"), in: data.currentSpaceID, now: Fixtures.now)
        try data.moveTab(tab, to: .essentials(index: 0))
        #expect(data.tab(tab)?.pinnedURL == Fixtures.url("mail"))
    }

    @Test func resetGoesBackToThePinnedURL() throws {
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(url: Fixtures.url("mail"), in: data.currentSpaceID, now: Fixtures.now)
        try data.pin(tab)
        try data.updatePage(tab, url: Fixtures.url("mail/inbox/42"), title: "Message", faviconURL: nil)
        try data.resetToPinnedURL(tab)
        #expect(data.tab(tab)?.url == Fixtures.url("mail"))
        #expect(data.tab(tab)?.title == "")
    }

    @Test func replaceMakesTheCurrentURLThePinnedOne() throws {
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(url: Fixtures.url("mail"), in: data.currentSpaceID, now: Fixtures.now)
        try data.addToEssentials(tab)
        try data.updatePage(tab, url: Fixtures.url("calendar"), title: "", faviconURL: nil)
        try data.replacePinnedURL(tab)
        #expect(data.tab(tab)?.pinnedURL == Fixtures.url("calendar"))
        try data.resetToPinnedURL(tab)
        #expect(data.tab(tab)?.url == Fixtures.url("calendar"))
    }

    @Test func regularTabsHaveNoPinnedURL() throws {
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(url: Fixtures.url("mail"), in: data.currentSpaceID, now: Fixtures.now)
        #expect(throws: ModelError.invalidTabLocation(tab)) { try data.resetToPinnedURL(tab) }
        #expect(throws: ModelError.invalidTabLocation(tab)) { try data.replacePinnedURL(tab) }
    }
}
