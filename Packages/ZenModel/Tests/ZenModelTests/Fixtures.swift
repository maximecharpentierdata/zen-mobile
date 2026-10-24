import Foundation

@testable import ZenModel

enum Fixtures {
    static let now = Date(timeIntervalSince1970: 1_000_000)

    static func url(_ path: String) -> URL? {
        URL(string: "https://example.com/\(path)")
    }

    /// First-launch data plus a second space called "Work".
    struct TwoSpaces {
        var data: BrowserData
        let personal: Space.ID
        let work: Space.ID
    }

    static func twoSpaces() -> TwoSpaces {
        var data = BrowserData.firstLaunch()
        let personal = data.currentSpaceID
        let work = data.addSpace(name: "Work", icon: "W", accentColor: 0xF0A060)
        return TwoSpaces(data: data, personal: personal, work: work)
    }
}
