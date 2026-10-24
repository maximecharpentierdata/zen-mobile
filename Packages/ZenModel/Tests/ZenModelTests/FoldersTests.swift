import Testing

@testable import ZenModel

@Suite struct FoldersTests {
    @Test func createNestedFolders() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let outer = try data.createFolder(named: "Outer", in: space)
        let inner = try data.createFolder(named: "Inner", in: space, parent: outer)
        let tab = try data.newTab(in: space, now: Fixtures.now)
        try data.pin(tab, into: inner)
        #expect(data.location(of: tab) == .pinned(space, folder: inner))
        #expect(data.currentSpace.pinned.first?.folder?.children.first?.folder?.id == inner)
    }

    @Test func renameAndToggle() throws {
        var data = BrowserData.firstLaunch()
        let folder = try data.createFolder(named: "Old", in: data.currentSpaceID)
        try data.renameFolder(folder, to: "New")
        try data.toggleFolder(folder)
        let stored = try #require(data.currentSpace.pinned.first?.folder)
        #expect(stored.name == "New")
        #expect(stored.isExpanded == false)
    }

    @Test func deleteFolderKeepsItsTabsInPlace() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let folder = try data.createFolder(named: "F", in: space)
        let tab = try data.newTab(in: space, now: Fixtures.now)
        try data.pin(tab, into: folder)
        try data.deleteFolder(folder)
        #expect(data.location(of: tab) == .pinned(space, folder: nil))
        #expect(data.currentSpace.pinned.count == 1)
    }

    @Test func folderCannotMoveIntoItsDescendant() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let outer = try data.createFolder(named: "Outer", in: space)
        let inner = try data.createFolder(named: "Inner", in: space, parent: outer)
        let before = data
        #expect(throws: ModelError.folderCycle) { try data.moveFolder(outer, into: inner, at: 0) }
        #expect(throws: ModelError.folderCycle) { try data.moveFolder(outer, into: outer, at: 0) }
        #expect(data == before)
    }

    @Test func moveFolderToRoot() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let outer = try data.createFolder(named: "Outer", in: space)
        let inner = try data.createFolder(named: "Inner", in: space, parent: outer)
        try data.moveFolder(inner, into: nil, at: 0)
        #expect(data.currentSpace.pinned.compactMap(\.folder?.id) == [inner, outer])
    }

    @Test func unknownFolderThrows() {
        var data = BrowserData.firstLaunch()
        let unknown = Folder.ID()
        #expect(throws: ModelError.folderNotFound(unknown)) { try data.toggleFolder(unknown) }
    }
}
