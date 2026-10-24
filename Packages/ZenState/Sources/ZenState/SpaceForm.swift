import Foundation

/// A space's name and icon as typed in the space editor, cleaned up (spec §3.7).
public struct SpaceForm: Equatable, Sendable {
    /// The name without surrounding spaces. Never empty.
    public let name: String
    /// The icon without surrounding spaces, or the name's first letter in upper case when none was typed.
    public let icon: String

    /// Cleans up the typed values. Returns `nil` when the name is blank, since a space needs a name.
    public init?(name: String, icon: String) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = name.first else { return nil }
        let icon = icon.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = name
        self.icon = icon.isEmpty ? String(first).uppercased() : icon
    }
}
