import ZenModel

/// Namespace for the persistence layer.
///
/// File storage arrives in milestone M1 (see `docs/roadmap.md`).
public enum ZenStore {
    /// The data format version this store reads and writes.
    public static let supportedSchemaVersion = ZenModel.schemaVersion
}
