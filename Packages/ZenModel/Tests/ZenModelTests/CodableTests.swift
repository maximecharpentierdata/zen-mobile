import Foundation
import Testing

@testable import ZenModel

@Suite struct CodableTests {
    @Test func browserDataRoundTripsThroughJSON() throws {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        let folder = try data.createFolder(named: "F", in: space)
        let pinned = try data.newTab(url: Fixtures.url("p"), in: space, now: Fixtures.now)
        try data.pin(pinned, into: folder)
        let essential = try data.newTab(url: Fixtures.url("e"), in: space, now: Fixtures.now)
        try data.addToEssentials(essential)
        _ = try data.newTab(url: Fixtures.url("r"), in: space, now: Fixtures.now)
        data.autoCloseDelay = .sevenDays

        let encoded = try JSONEncoder().encode(data)
        let decoded = try JSONDecoder().decode(BrowserData.self, from: encoded)

        #expect(decoded == data)
    }
}
