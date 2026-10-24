/// Why stored data couldn't be read.
public enum StoreError: Error, Equatable, Sendable {
    /// The file was written by a newer version of the app.
    case unsupportedSchemaVersion(Int)
    /// The file decodes but breaks a model rule, for example it has no space.
    case invalidData
}
