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

    @Test func blankFolderNameDoesNothing() throws {
        let state = makeState()
        let tab = try #require(state.newTab())
        state.moveTabToNewFolder(tab, named: " ")
        #expect(state.data.currentSpace.pinned.isEmpty)
        #expect(state.data.location(of: tab) == .regular(state.data.currentSpaceID))
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
}
