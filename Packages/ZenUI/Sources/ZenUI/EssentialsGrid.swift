import SwiftUI
import ZenModel

/// Favourite sites shared by all spaces, as a 4-column grid of icons (spec §3.2).
struct EssentialsGrid: View {
    let tabs: [ZenModel.Tab]
    let accent: UInt32
    let menus: RowMenus
    let onOpen: @MainActor (ZenModel.Tab.ID) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Theme.Spacing.grid),
        count: Theme.essentialsColumns
    )

    /// Double-tapping an Essential goes back to its pinned URL (spec §3.2).
    private func openPinnedPage(_ id: ZenModel.Tab.ID) {
        menus.goToPinnedURL(id)
        onOpen(id)
    }

    /// The whole grid accepts drops, at the end, so a tab can join Essentials even when the grid is empty or full.
    var body: some View {
        Group {
            if tabs.isEmpty {
                DropPlaceholder(
                    text: "Drag a tab here to add it to Essentials",
                    height: Theme.Size.essentialTileHeight,
                    cornerRadius: Theme.Radius.essentialTile
                )
            } else {
                grid
            }
        }
        .dropsTab(state: menus.state) { .essentials(index: .max) }
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.grid) {
            ForEach(tabs) { tab in
                FaviconBadge(tab: tab, accent: accent, size: Theme.Size.essentialIcon)
                    .frame(maxWidth: .infinity, minHeight: Theme.Size.essentialTileHeight)
                    .background(Theme.Palette.tileFill, in: .rect(cornerRadius: Theme.Radius.essentialTile))
                    .reportsRowFrame(for: tab.id)
                    .onTap({ onOpen(tab.id) }, doubleTap: { openPinnedPage(tab.id) })
                    .contextMenu { menus.tabMenu(for: tab) }
                    .reorderableTab(tab.id, state: menus.state)
                    .accessibilityLabel(tab.title.isEmpty ? (tab.url?.host() ?? "") : tab.title)
            }
        }
    }
}
