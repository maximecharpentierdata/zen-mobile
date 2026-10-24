import Foundation
import Testing
import ZenModel

@testable import ZenState

@MainActor
@Suite struct OrganizeIntentTests {
    private func makeState() -> BrowserState {
        BrowserState(data: .firstLaunch(), saveDelay: .seconds(3600))
    }

    @Test func moveRegularTabToNewFolderPinsIt() throws {
        let state = makeState()
        let space = state.data.currentSpaceID
        let tab = try #require(state.newTab())
        state.moveTabToNewFolder(tab, named: "  Reading ")
        let folder = try #require(state.data.currentSpace.pinned.first?.folder)
        #expect(folder.name == "Reading")
        #expect(state.data.location(of: tab) == .pinned(space, folder: folder.id))
    }

    @Test func createEmptyFolderAtTheEndOfThePinnedSection() throws {
        let state = makeState()
        let space = state.data.currentSpaceID
        let tab = try #require(state.newTab())
        state.pin(tab)
        state.createFolder(named: " Work ", in: space)
        state.createFolder(named: " ", in: space)
        #expect(state.data.currentSpace.pinned.count == 2)
        let folder = try #require(state.data.currentSpace.pinned.last?.folder)
        #expect(folder.name == "Work")
        #expect(folder.children.isEmpty)
    }

    @Test func blankFolderNameDoesNothing() throws {
        let state = makeState()
        let tab = try #require(state.newTab())
        state.moveTabToNewFolder(tab, named: " ")
        #expect(state.data.currentSpace.pinned.isEmpty)
        #expect(state.data.location(of: tab) == .regular(state.data.currentSpaceID))
    }

    @Test func pinnedURLResetAndReplace() throws {
        let state = makeState()
        let tab = try #require(state.newTab(url: URL(string: "https://example.com/mail")))
        state.pin(tab)
        state.pageDidChange(tab, url: URL(string: "https://example.com/mail/42"), title: "Message")
        state.resetToPinnedURL(tab)
        #expect(state.data.tab(tab)?.url?.absoluteString == "https://example.com/mail")
        state.pageDidChange(tab, url: URL(string: "https://example.com/inbox"), title: "Inbox")
        state.replacePinnedURL(tab)
        #expect(state.data.tab(tab)?.pinnedURL?.absoluteString == "https://example.com/inbox")
    }

    /// The whole path of a new Essential: typed in a new tab, dropped on Essentials, then browsed from.
    @Test func essentialKeepsItsPinnedURLWhileBrowsing() throws {
        let state = makeState()
        let mail = URL(string: "https://example.com/mail")
        state.startNewTab()
        state.submitAddress("https://example.com/mail")
        let tab = try #require(state.openTabID)
        state.showSpace()
        state.moveTab(tab, to: .essentials(index: 0))
        state.open(tab)
        state.pageDidChange(tab, url: URL(string: "https://example.com/mail/42"), title: "Message")
        state.submitAddress("https://example.com/calendar")
        #expect(state.openTabID != tab)
        #expect(state.data.tab(tab)?.pinnedURL == mail)
        state.resetToPinnedURL(tab)
        #expect(state.data.tab(tab)?.url == mail)
    }

    @Test func movePinnedTabToAnotherFolder() throws {
        let state = makeState()
        let space = state.data.currentSpaceID
        let first = try #require(state.newTab())
        let second = try #require(state.newTab())
        state.moveTabToNewFolder(first, named: "A")
        let folder = try #require(state.data.currentSpace.pinned.first?.folder?.id)
        state.pin(second)
        state.moveTab(second, toFolder: folder)
        #expect(state.data.location(of: second) == .pinned(space, folder: folder))
    }

    @Test func essentialsRoundTripToTheCurrentSpace() throws {
        let state = makeState()
        let tab = try #require(state.newTab())
        state.addToEssentials(tab)
        #expect(state.data.location(of: tab) == .essentials)
        state.removeFromEssentials(tab)
        #expect(state.data.location(of: tab) == .regular(state.data.currentSpaceID))
    }

    @Test func duplicateAndFolderEdits() throws {
        let state = makeState()
        let tab = try #require(state.newTab())
        state.duplicateTab(tab)
        #expect(state.data.currentSpace.regular.count == 2)
        state.moveTabToNewFolder(tab, named: "A")
        let folder = try #require(state.data.currentSpace.pinned.first?.folder?.id)
        state.renameFolder(folder, to: "")
        #expect(state.data.currentSpace.pinned.first?.folder?.name == "A")
        state.renameFolder(folder, to: "B")
        #expect(state.data.currentSpace.pinned.first?.folder?.name == "B")
        state.deleteFolder(folder)
        #expect(state.data.currentSpace.pinned.first?.tab?.id == tab)
    }

    @Test func dragAndDropMovesTheTab() throws {
        let state = makeState()
        let first = try #require(state.newTab())
        let second = try #require(state.newTab())
        state.moveTab(second, to: .pinned(state.data.currentSpaceID, folder: nil, index: 0))
        #expect(state.data.currentSpace.pinned.first?.tab?.id == second)
        #expect(state.data.currentSpace.regular.map(\.id) == [first])
    }
}
