import Foundation
import ZenModel
import ZenState

/// Sample content for Xcode previews only. Never used by the app itself.
@MainActor
enum PreviewData {
    static func state() -> BrowserState {
        var data = BrowserData.firstLaunch()
        let space = data.currentSpaceID
        _ = data.addSpace(name: "Work", icon: "W", accentColor: 0xF0A060)
        for title in ["Mail", "Calendar", "Music", "Notes"] {
            if let id = addTab(title, in: space, to: &data) {
                try? data.addToEssentials(id)
            }
        }
        if let folder = try? data.createFolder(named: "Reading list", in: space) {
            for title in ["Long read", "Recipe"] {
                if let id = addTab(title, in: space, to: &data) {
                    try? data.pin(id, into: folder)
                }
            }
        }
        for title in ["Weekend weather", "Hiking boots size guide", "Encyclopedia — Alps"] {
            addTab(title, in: space, to: &data)
        }
        return BrowserState(data: data)
    }

    @discardableResult
    private static func addTab(
        _ title: String,
        in space: Space.ID,
        to data: inout BrowserData
    ) -> ZenModel.Tab.ID? {
        guard let id = try? data.newTab(in: space, now: Date()) else { return nil }
        try? data.updatePage(id, url: URL(string: "https://example.com"), title: title, faviconURL: nil)
        return id
    }
}
