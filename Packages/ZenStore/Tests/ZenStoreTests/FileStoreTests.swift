import Foundation
import Testing
import ZenModel

@testable import ZenStore

@Suite struct FileStoreTests {
    private let store = FileStore(
        fileURL: FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("browser.json")
    )

    @Test func loadReturnsNilWhenNothingWasSaved() throws {
        #expect(try store.load() == nil)
    }

    @Test func saveThenLoadRoundTrips() throws {
        var data = BrowserData.firstLaunch()
        _ = try data.newTab(url: URL(string: "https://example.com"), in: data.currentSpaceID, now: Date())
        try store.save(data)
        #expect(try store.load() == data)
    }

    @Test func saveReplacesPreviousContent() throws {
        var data = BrowserData.firstLaunch()
        try store.save(data)
        data.addSpace(name: "Work", icon: "W", accentColor: 0xF0A060)
        try store.save(data)
        #expect(try store.load()?.spaces.count == 2)
    }

    @Test func newerSchemaVersionIsRefused() throws {
        try write(#"{"schemaVersion": 99, "data": {}}"#)
        #expect(throws: StoreError.unsupportedSchemaVersion(99)) { try store.load() }
    }

    @Test func dataWithoutSpacesIsRefused() throws {
        let current = UUID().uuidString
        let json = """
            {"schemaVersion": 1, "data": {"spaces": [], "currentSpaceID": {"rawValue": "\(current)"},
            "essentials": [], "recentlyClosed": [], "autoCloseDelay": "oneDay"}}
            """
        try write(json)
        #expect(throws: StoreError.invalidData) { try store.load() }
    }

    @Test func corruptFileThrows() throws {
        try write("not json")
        #expect(throws: (any Error).self) { try store.load() }
    }

    private func write(_ text: String) throws {
        try FileManager.default.createDirectory(
            at: store.fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data(text.utf8).write(to: store.fileURL)
    }
}
