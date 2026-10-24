import Foundation

extension FileStore {
    /// Moves an unreadable file aside, next to the original, so starting fresh never destroys the user's data.
    /// Returns where the file went, or `nil` when there was no file.
    @discardableResult
    public func moveAside(now: Date = Date()) throws -> URL? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let stamp = Int(now.timeIntervalSince1970)
        let destination = fileURL.deletingPathExtension().appendingPathExtension("unreadable-\(stamp).json")
        try FileManager.default.moveItem(at: fileURL, to: destination)
        return destination
    }
}
