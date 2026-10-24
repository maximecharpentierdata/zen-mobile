import Testing

@testable import ZenModel

@Suite struct MoveTabTests {
    private struct Setup {
        var data = BrowserData.firstLaunch()
        var space: Space.ID { data.currentSpaceID }
        var regular: [Tab.ID] = []

        init() throws {
            let space = data.currentSpaceID
            for name in ["c", "b", "a"] {
                regular.insert(try data.newTab(url: Fixtures.url(name), in: space, now: Fixtures.now), at: 0)
            }
        }
    }

    @Test func movingDownWithinTheSameListLandsBeforeTheTarget() throws {
        var setup = try Setup()
        let ids = setup.regular
        try setup.data.moveTab(ids[0], to: .regular(setup.space, index: 2))
        #expect(setup.data.currentSpace.regular.map(\.id) == [ids[1], ids[0], ids[2]])
    }

    @Test func movingUpWithinTheSameList() throws {
        var setup = try Setup()
        let ids = setup.regular
        try setup.data.moveTab(ids[2], to: .regular(setup.space, index: 0))
        #expect(setup.data.currentSpace.regular.map(\.id) == [ids[2], ids[0], ids[1]])
    }

    @Test func droppingAboveTheDividerPinsIntoAFolder() throws {
        var setup = try Setup()
        let folder = try setup.data.createFolder(named: "F", in: setup.space)
        let tab = setup.regular[1]
        try setup.data.moveTab(tab, to: .pinned(setup.space, folder: folder, index: 0))
        #expect(setup.data.location(of: tab) == .pinned(setup.space, folder: folder))
        #expect(setup.data.tab(tab)?.pinnedURL == Fixtures.url("b"))
    }

    @Test func droppingBelowTheDividerUnpins() throws {
        var setup = try Setup()
        let tab = setup.regular[0]
        try setup.data.pin(tab)
        try setup.data.moveTab(tab, to: .regular(setup.space, index: 1))
        #expect(setup.data.currentSpace.regular.map(\.id) == [setup.regular[1], tab, setup.regular[2]])
        #expect(setup.data.tab(tab)?.pinnedURL == nil)
    }

    @Test func essentialsReorderAndReceiveTabs() throws {
        var setup = try Setup()
        try setup.data.moveTab(setup.regular[0], to: .essentials(index: 0))
        try setup.data.moveTab(setup.regular[1], to: .essentials(index: 0))
        #expect(setup.data.essentials.map(\.id) == [setup.regular[1], setup.regular[0]])
        try setup.data.moveTab(setup.regular[1], to: .essentials(index: 2))
        #expect(setup.data.essentials.map(\.id) == [setup.regular[0], setup.regular[1]])
    }

    @Test func movingToAnotherSpaceKeepsThePinnedURLOfPinnedTabs() throws {
        var setup = try Setup()
        let other = setup.data.addSpace(name: "Work", icon: "W", accentColor: 0)
        let tab = setup.regular[0]
        try setup.data.pin(tab)
        try setup.data.moveTab(tab, to: .pinned(other, folder: nil, index: 0))
        #expect(setup.data.location(of: tab) == .pinned(other, folder: nil))
        #expect(setup.data.tab(tab)?.pinnedURL == Fixtures.url("a"))
    }

    @Test func invalidDestinationsThrowAndKeepTheTab() throws {
        var setup = try Setup()
        let tab = setup.regular[0]
        let unknownFolder = Folder.ID()
        #expect(throws: ModelError.folderNotFound(unknownFolder)) {
            try setup.data.moveTab(tab, to: .pinned(setup.space, folder: unknownFolder, index: 0))
        }
        let unknownSpace = Space.ID()
        #expect(throws: ModelError.spaceNotFound(unknownSpace)) {
            try setup.data.moveTab(tab, to: .regular(unknownSpace, index: 0))
        }
        #expect(setup.data.location(of: tab) == .regular(setup.space))
    }

    @Test func reorderingPinnedItemsCountsFolders() throws {
        var setup = try Setup()
        let ids = setup.regular
        try setup.data.pin(ids[0])
        let folder = try setup.data.createFolder(named: "F", in: setup.space)
        try setup.data.pin(ids[1])
        try setup.data.moveTab(ids[0], to: .pinned(setup.space, folder: nil, index: 3))
        let pinned = setup.data.currentSpace.pinned
        #expect(pinned.map(\.tab?.id) == [nil, ids[1], ids[0]])
        #expect(pinned.first?.folder?.id == folder)
    }

    @Test func destinationBeforeATab() throws {
        var setup = try Setup()
        let ids = setup.regular
        let folder = try setup.data.createFolder(named: "F", in: setup.space)
        try setup.data.pin(ids[2], into: folder)
        #expect(setup.data.destination(before: ids[1]) == .regular(setup.space, index: 1))
        #expect(setup.data.destination(before: ids[2]) == .pinned(setup.space, folder: folder, index: 0))
        try setup.data.addToEssentials(ids[0])
        #expect(setup.data.destination(before: ids[0]) == .essentials(index: 0))
        #expect(setup.data.destination(before: Tab.ID()) == nil)
    }
}
