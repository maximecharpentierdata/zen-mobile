import Foundation

/// A typed, stable identifier. The phantom `Owner` type stops a tab id from being used as a space id.
public struct Identifier<Owner>: Hashable, Codable, Sendable, CustomStringConvertible {
    /// The underlying unique value.
    public let rawValue: UUID

    /// Creates an identifier from an existing value, or a new random one.
    public init(_ rawValue: UUID = UUID()) {
        self.rawValue = rawValue
    }

    /// The identifier as a UUID string.
    public var description: String { rawValue.uuidString }
}
