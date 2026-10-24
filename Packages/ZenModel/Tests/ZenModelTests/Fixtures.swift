import Foundation

@testable import ZenModel

enum Fixtures {
    static let now = Date(timeIntervalSince1970: 1_000_000)

    static func url(_ path: String) -> URL? {
        URL(string: "https://example.com/\(path)")
    }

    /// First-launch data plus a second space called "Work".
    static func twoSpaces() -> (data: BrowserData, personal: Space.ID, work: Space.ID) {
        var data = BrowserData.firstLaunch()
        let personal = data.currentSpaceID
        let work = data.addSpace(name: "Work", icon: "W", accentColor: 0xF0A060)
        return (data, personal, work)
    }
}
