import Testing
import ZenModel

@testable import ZenStore

@Test func storeSupportsCurrentSchema() {
    #expect(ZenStore.supportedSchemaVersion == ZenModel.schemaVersion)
}
