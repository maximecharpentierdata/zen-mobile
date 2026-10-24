import Foundation
import Testing
import ZenModel

@testable import ZenState

@Suite struct PinnedRowTests {
    private let now = Date(timeIntervalSince1970: 0)

    @Test func flattensExpandedFoldersWithDepth() {
        let inner = Tab(title: "Inner", lastAccessed: now)
        let root = Tab(title: "Root", lastAccessed: now)
        let folder = Folder(name: "F", children: [.tab(inner)])
        let rows = PinnedRow.rows(for: [.folder(folder), .tab(root)])
        #expect(rows == [.folder(folder, depth: 0, tabCount: 1), .tab(inner, depth: 1), .tab(root, depth: 0)])
    }

    @Test func hidesChildrenOfCollapsedFolders() {
        let inner = Tab(title: "Inner", lastAccessed: now)
        let folder = Folder(name: "F", isExpanded: false, children: [.tab(inner)])
        #expect(PinnedRow.rows(for: [.folder(folder)]) == [.folder(folder, depth: 0, tabCount: 1)])
    }

    @Test func countsTabsInNestedFolders() {
        let deep = Folder(name: "Deep", children: [.tab(Tab(lastAccessed: now)), .tab(Tab(lastAccessed: now))])
        let outer = Folder(name: "Outer", isExpanded: false, children: [.folder(deep), .tab(Tab(lastAccessed: now))])
        #expect(PinnedRow.rows(for: [.folder(outer)]) == [.folder(outer, depth: 0, tabCount: 3)])
    }

    @Test func listsAllFoldersIncludingCollapsedOnes() {
        let deep = Folder(name: "Deep")
        let outer = Folder(name: "Outer", isExpanded: false, children: [.folder(deep)])
        let other = Folder(name: "Other")
        let tab = Tab(lastAccessed: now)
        let folders = PinnedRow.allFolders(in: [.folder(outer), .tab(tab), .folder(other)])
        #expect(folders.map(\.name) == ["Outer", "Deep", "Other"])
    }
}
