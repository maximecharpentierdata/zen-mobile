import Foundation
import ZenModel

/// The user actions the interface calls. Each one is a single model change (spec §3).
extension BrowserState {
    /// Opens a new tab at the top of the current space's regular tabs and returns its id (spec §3.6).
    @discardableResult
    public func newTab(url: URL? = nil) -> Tab.ID? {
        var id: Tab.ID?
        let time = now
        perform { data in
            id = try data.newTab(url: url, in: data.currentSpaceID, now: time)
        }
        return id
    }

    /// Closes a tab (spec §3.2).
    public func closeTab(_ id: Tab.ID) {
        perform { try $0.closeTab(id) }
    }

    /// Expands or collapses a folder (spec §3.2).
    public func toggleFolder(_ id: Folder.ID) {
        perform { try $0.toggleFolder(id) }
    }

    /// Shows another space (spec §3.3).
    public func selectSpace(_ id: Space.ID) {
        perform { try $0.selectSpace(id) }
    }

    /// Shows the space `step` places after the current one, or before it when `step` is negative. Does nothing
    /// past the first or last space. It is the non-gesture alternative to swiping (spec §3.3, §5).
    public func selectSpace(step: Int) {
        let spaces = data.spaces
        guard let index = spaces.firstIndex(where: { $0.id == data.currentSpaceID }),
            spaces.indices.contains(index + step)
        else { return }
        selectSpace(spaces[index + step].id)
    }

    /// Records that a tab was opened, which resets its clean-up timer (spec §3.2).
    public func recordAccess(_ id: Tab.ID) {
        let time = now
        perform { try $0.recordAccess(id, now: time) }
    }

    /// Closes regular tabs that weren't opened within the chosen delay (spec §3.2). Call it when the app
    /// becomes active.
    public func closeStaleTabs() {
        let time = now
        perform { _ = $0.closeStaleTabs(now: time) }
    }
}
