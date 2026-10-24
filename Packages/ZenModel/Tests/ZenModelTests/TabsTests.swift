import Foundation
import Testing

@testable import ZenModel

@Suite struct TabsTests {
    @Test func newTabGoesFirstInRegularTabs() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let first = try data.newTab(url: Fixtures.url("1"), in: space, now: Fixtures.now)
        let second = try data.newTab(url: Fixtures.url("2"), in: space, now: Fixtures.now)
        #expect(data.currentSpace.regular.map(\.id) == [second, first])
        #expect(data.location(of: first) == .regular(space))
    }

    @Test func closeTabMovesItToRecentlyClosed() throws {
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(in: data.currentSpaceID, now: Fixtures.now)
        try data.closeTab(tab)
        #expect(data.location(of: tab) == nil)
        #expect(data.recentlyClosed.map(\.id) == [tab])
    }

    @Test func closeUnknownTabThrows() {
        var data = BrowserData.firstLaunch()
        let unknown = Tab.ID()
        #expect(throws: ModelError.tabNotFound(unknown)) { try data.closeTab(unknown) }
    }

    @Test func recentlyClosedIsCapped() throws {
        var data = BrowserData.firstLaunch()
        for _ in 0..<(BrowserData.recentlyClosedLimit + 5) {
            let tab = try data.newTab(in: data.currentSpaceID, now: Fixtures.now)
            try data.closeTab(tab)
        }
        #expect(data.recentlyClosed.count == BrowserData.recentlyClosedLimit)
    }

    @Test func restoreClosedTabPutsItBackFirst() throws {
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(in: data.currentSpaceID, now: Fixtures.now)
        try data.closeTab(tab)
        let later = Fixtures.now.addingTimeInterval(60)
        try data.restoreClosedTab(tab, now: later)
        #expect(data.currentSpace.regular.map(\.id) == [tab])
        #expect(data.tab(tab)?.lastAccessed == later)
        #expect(data.recentlyClosed.isEmpty)
    }

    @Test func updatePageAndRecordAccess() throws {
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(in: data.currentSpaceID, now: Fixtures.now)
        try data.updatePage(tab, url: Fixtures.url("page"), title: "Page", faviconURL: Fixtures.url("icon"))
        let later = Fixtures.now.addingTimeInterval(10)
        try data.recordAccess(tab, now: later)
        let updated = try #require(data.tab(tab))
        #expect(updated.url == Fixtures.url("page"))
        #expect(updated.title == "Page")
        #expect(updated.faviconURL == Fixtures.url("icon"))
        #expect(updated.lastAccessed == later)
    }

    @Test func staleRegularTabsCloseButPinnedAndEssentialsStay() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let stale = try data.newTab(in: space, now: Fixtures.now)
        let pinned = try data.newTab(in: space, now: Fixtures.now)
        try data.pin(pinned)
        let essential = try data.newTab(in: space, now: Fixtures.now)
        try data.addToEssentials(essential)
        let dayLater = Fixtures.now.addingTimeInterval(24 * 3600)
        let fresh = try data.newTab(in: space, now: dayLater)

        let closed = data.closeStaleTabs(now: dayLater.addingTimeInterval(1))

        #expect(closed == [stale])
        #expect(data.currentSpace.regular.map(\.id) == [fresh])
        #expect(data.location(of: pinned) == .pinned(space, folder: nil))
        #expect(data.location(of: essential) == .essentials)
    }

    @Test func neverDelayClosesNothing() throws {
        var data = BrowserData.firstLaunch()
        data.autoCloseDelay = .never
        _ = try data.newTab(in: data.currentSpaceID, now: Fixtures.now)
        #expect(data.closeStaleTabs(now: Fixtures.now.addingTimeInterval(1_000_000)).isEmpty)
    }

    @Test func autoCloseDelayIntervals() {
        #expect(AutoCloseDelay.twelveHours.interval == 43_200)
        #expect(AutoCloseDelay.oneDay.interval == 86_400)
        #expect(AutoCloseDelay.sevenDays.interval == 604_800)
        #expect(AutoCloseDelay.never.interval == nil)
    }

    @Test func allTabIDsListsOpenTabsOnly() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let essential = try data.newTab(in: space, now: Fixtures.now)
        try data.addToEssentials(essential)
        let pinned = try data.newTab(in: space, now: Fixtures.now)
        try data.pin(pinned)
        let regular = try data.newTab(in: space, now: Fixtures.now)
        let closed = try data.newTab(in: space, now: Fixtures.now)
        try data.closeTab(closed)
        #expect(data.allTabIDs == [essential, pinned, regular])
    }
}
