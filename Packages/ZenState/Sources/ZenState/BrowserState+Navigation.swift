import Foundation
import ZenModel

/// Moving between the space screen, pages and the address field (spec §3.4–3.6).
extension BrowserState {
    /// The tab shown full screen, if it still exists.
    public var openTab: Tab? {
        openTabID.flatMap { data.tab($0) }
    }

    /// Shows a tab full screen and resets its clean-up timer (spec §3.4).
    public func open(_ id: Tab.ID) {
        guard data.tab(id) != nil else { return }
        recordAccess(id)
        openTabID = id
        isEditingAddress = false
    }

    /// Goes back to the space screen (spec §3.5, stop 1).
    public func showSpace() {
        openTabID = nil
        isEditingAddress = false
    }

    /// Creates a tab, shows it and opens the address field (spec §3.5 stop 2, §3.6).
    public func startNewTab() {
        guard let id = newTab() else { return }
        openTabID = id
        isEditingAddress = true
    }

    /// Opens the address field for the current page.
    public func editAddress() {
        isEditingAddress = true
    }

    /// Closes the address field without loading anything. An empty new tab is closed again, so cancelling
    /// "new tab" leaves nothing behind.
    public func cancelAddressEditing() {
        isEditingAddress = false
        if let tab = openTab, tab.url == nil {
            closeTab(tab.id)
            showSpace()
        }
    }

    /// Loads what the user typed (spec §3.6). Blank text changes nothing. A regular tab loads it in place; a
    /// pinned tab or an Essential keeps its page, and the address opens in a new tab.
    public func submitAddress(_ text: String) {
        guard let url = AddressInput.url(for: text, engine: searchEngine), let tab = openTab else { return }
        if case .regular = data.location(of: tab.id) {
            perform { try $0.updatePage(tab.id, url: url, title: "", faviconURL: nil) }
        } else if let id = newTab(url: url) {
            openTabID = id
        }
        isEditingAddress = false
    }

    /// Records what a page shows after a navigation, as reported by the web view.
    public func pageDidChange(_ id: Tab.ID, url: URL?, title: String) {
        guard let tab = data.tab(id), tab.url != url || tab.title != title else { return }
        perform { try $0.updatePage(id, url: url, title: title, faviconURL: tab.faviconURL) }
    }
}
