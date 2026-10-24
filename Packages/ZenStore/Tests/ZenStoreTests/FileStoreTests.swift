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

    /// Files saved before pinned URLs existed: an Essential opened, navigated, then double-tapped stayed on the
    /// page it had navigated to, as if its URL had been replaced.
    @Test func essentialsSavedWithoutAPinnedURLGoBackToTheirURL() throws {
        let mail = URL(string: "https://example.com/mail")
        var data = BrowserData.firstLaunch()
        let tab = try data.newTab(url: mail, in: data.currentSpaceID, now: Date())
        try data.addToEssentials(tab)
        try store.save(data)
        try removePinnedURLs()
        var loaded = try #require(try store.load())
        try loaded.updatePage(tab, url: URL(string: "https://example.com/mail/42"), title: "Message", faviconURL: nil)
        try loaded.resetToPinnedURL(tab)
        #expect(loaded.tab(tab)?.url == mail)
    }

    /// Rewrites the saved file as an older version wrote it, without the `pinnedURL` of any tab.
    private func removePinnedURLs() throws {
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: store.fileURL))
        let stripped = Self.removingKey("pinnedURL", from: json)
        try JSONSerialization.data(withJSONObject: stripped).write(to: store.fileURL)
    }

    private static func removingKey(_ key: String, from json: Any) -> Any {
        if let object = json as? [String: Any] {
            return object.filter { $0.key != key }.mapValues { removingKey(key, from: $0) }
        }
        if let array = json as? [Any] {
            return array.map { removingKey(key, from: $0) }
        }
        return json
    }

    private func write(_ text: String) throws {
        try FileManager.default.createDirectory(
            at: store.fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data(text.utf8).write(to: store.fileURL)
    }
}

@Suite struct FileStoreRecoveryTests {
    private let store = FileStore(
        fileURL: FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("browser.json")
    )

    @Test func moveAsideKeepsTheFileUnderANewName() throws {
        try store.save(BrowserData.firstLaunch())
        let moved = try #require(try store.moveAside(now: Date(timeIntervalSince1970: 42)))
        #expect(moved.lastPathComponent == "browser.unreadable-42.json")
        #expect(FileManager.default.fileExists(atPath: moved.path))
        #expect(try store.load() == nil)
    }

    @Test func moveAsideWithoutFileReturnsNil() throws {
        #expect(try store.moveAside() == nil)
    }
}
