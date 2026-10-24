/// Namespace for facts about the Zen data model as a whole.
///
/// The model types (spaces, tabs, folders, Essentials) arrive in milestone M1 (see `docs/roadmap.md`).
public enum ZenModel {
    /// The version of the persisted data format. Increase it with every incompatible change.
    public static let schemaVersion = 1
}
