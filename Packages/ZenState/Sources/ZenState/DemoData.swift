import Foundation
import ZenModel

/// Sample content for previews, CI screenshots and demos. The app uses it only in debug builds, when the
/// `ZEN_DEMO_DATA` environment variable is `1`.
public enum DemoData {
    /// Two spaces; the first has Essentials, a folder with pinned tabs, and regular tabs (design 1A).
    public static func browserData(now: Date) -> BrowserData {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        data.addSpace(name: "Work", icon: "W", accentColor: 0xF0A060)
        data.addSpace(name: "Research", icon: "R", accentColor: 0x5CC8BE)
        for title in ["Mail", "Calendar", "Music", "Notes"] {
            if let id = addTab(title, in: space, now: now, to: &data) {
                try? data.addToEssentials(id)
            }
        }
        if let folder = try? data.createFolder(named: "Reading list", in: space) {
            for title in ["Long read: how cities plan transit", "Recipe — miso aubergine"] {
                if let id = addTab(title, in: space, now: now, to: &data) {
                    try? data.pin(id, into: folder)
                }
            }
        }
        for title in ["Video: knot tying basics", "Encyclopedia — Alps", "Hiking boots size guide", "Weekend weather"] {
            addTab(title, in: space, now: now, to: &data)
        }
        return data
    }

    @discardableResult
    private static func addTab(_ title: String, in space: Space.ID, now: Date, to data: inout BrowserData)
        -> Tab.ID?
    {
        guard let id = try? data.newTab(in: space, now: now) else { return nil }
        try? data.updatePage(id, url: URL(string: "https://example.com"), title: title, faviconURL: nil)
        return id
    }
}
