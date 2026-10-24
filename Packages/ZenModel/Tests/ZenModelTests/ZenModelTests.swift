import Testing

@testable import ZenModel

@Test func schemaVersionStartsAtOne() {
    #expect(ZenModel.schemaVersion == 1)
}
