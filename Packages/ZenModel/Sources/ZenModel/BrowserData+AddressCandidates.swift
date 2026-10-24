/// The pages the address field suggests (spec §3.4, §3.6).
extension BrowserData {
    /// Every page with an address, in the order suggestions prefer them: Essentials, the current space's pinned
    /// and regular tabs, the other spaces' tabs, then recently closed tabs.
    public var addressCandidates: [Tab] {
        let current = currentSpace
        let spaceOrder = [current] + spaces.filter { $0.id != current.id }
        let spaceTabs = spaceOrder.flatMap { $0.pinned.flatMap(\.allTabs) + $0.regular }
        return (essentials + spaceTabs + recentlyClosed).filter { $0.url != nil }
    }
}
