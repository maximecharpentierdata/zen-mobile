import Foundation
import ZenModel

/// Reads and writes ``BrowserData`` as a versioned JSON file.
public struct FileStore: Sendable {
    /// The version of the file format written by this code. Increase it with every incompatible change.
    public static let schemaVersion = 1

    /// Where the data lives.
    public let fileURL: URL

    /// Creates a store for the file at `fileURL`. Nothing is read or written until ``load()`` or ``save(_:)``.
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Reads the stored data, or returns `nil` when nothing has been saved yet.
    public func load() throws -> BrowserData? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let bytes = try Data(contentsOf: fileURL)
        let version = try JSONDecoder().decode(VersionProbe.self, from: bytes).schemaVersion
        guard version <= Self.schemaVersion else { throw StoreError.unsupportedSchemaVersion(version) }
        let data = try JSONDecoder().decode(Envelope.self, from: bytes).data
        guard !data.spaces.isEmpty, data.space(data.currentSpaceID) != nil else { throw StoreError.invalidData }
        return data
    }

    /// Writes the data atomically, so a crash during the write never leaves a half-written file.
    public func save(_ data: BrowserData) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let bytes = try encoder.encode(Envelope(schemaVersion: Self.schemaVersion, data: data))
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try bytes.write(to: fileURL, options: .atomic)
    }
}

private struct Envelope: Codable {
    let schemaVersion: Int
    let data: BrowserData
}

private struct VersionProbe: Decodable {
    let schemaVersion: Int
}
