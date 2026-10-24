import Foundation
import Testing
import ZenModel
import ZenStore

@testable import ZenState

@MainActor
@Suite struct BrowserStateTests {
    private let store = FileStore(
        fileURL: FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("browser.json")
    )
    nonisolated private static let fixedNow = Date(timeIntervalSince1970: 1_000_000)

    private func makeState(store: FileStore? = nil) -> BrowserState {
        BrowserState(data: .firstLaunch(), store: store, saveDelay: .seconds(3600), clock: { Self.fixedNow })
    }

    @Test func newTabUsesTheClockAndTheCurrentSpace() throws {
        let state = makeState()
        let id = try #require(state.newTab())
        #expect(state.data.location(of: id) == .regular(state.data.currentSpaceID))
        #expect(state.data.tab(id)?.lastAccessed == Self.fixedNow)
    }

    @Test func refusedChangeKeepsDataAndRecordsError() {
        let state = makeState()
        let before = state.data
        let applied = state.perform { try $0.deleteSpace($0.currentSpaceID, tabs: .close) }
        #expect(applied == false)
        #expect(state.data == before)
        #expect(state.lastError as? ModelError == .cannotDeleteLastSpace)
    }

    @Test func saveNowWritesToTheStore() throws {
        let state = makeState(store: store)
        state.newTab()
        state.saveNow()
        #expect(try store.load() == state.data)
    }

    @Test func loadStartsFreshWhenNothingIsSaved() {
        let state = BrowserState.load(from: store)
        #expect(state.data.spaces.map(\.name) == ["Personal"])
    }

    @Test func loadMovesAnUnreadableFileAside() throws {
        try FileManager.default.createDirectory(
            at: store.fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("broken".utf8).write(to: store.fileURL)
        let state = BrowserState.load(from: store)
        #expect(state.data.spaces.count == 1)
        let folder = store.fileURL.deletingLastPathComponent()
        let names = try FileManager.default.contentsOfDirectory(atPath: folder.path)
        #expect(names.contains { $0.hasPrefix("browser.unreadable-") })
    }

    @Test func toggleFolderAndSelectSpace() throws {
        let state = makeState()
        var folder: Folder.ID?
        state.perform { data in
            folder = try data.createFolder(named: "F", in: data.currentSpaceID)
        }
        let folderID = try #require(folder)
        state.toggleFolder(folderID)
        #expect(state.data.currentSpace.pinned.first?.folder?.isExpanded == false)

        var work: Space.ID?
        state.perform { work = $0.addSpace(name: "Work", icon: "W", accentColor: 0xF0A060) }
        let workID = try #require(work)
        state.selectSpace(workID)
        #expect(state.data.currentSpaceID == workID)
    }
}
