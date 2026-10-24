import SwiftUI
import ZenModel

/// Favourite sites shared by all spaces, as a 4-column grid of icons (spec §3.2).
struct EssentialsGrid: View {
    let tabs: [ZenModel.Tab]
    let accent: UInt32
    let onOpen: @MainActor (ZenModel.Tab.ID) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Theme.Spacing.grid),
        count: Theme.essentialsColumns
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.grid) {
            ForEach(tabs) { tab in
                Button {
                    onOpen(tab.id)
                } label: {
                    FaviconBadge(tab: tab, accent: accent, size: Theme.Size.essentialIcon)
                        .frame(maxWidth: .infinity, minHeight: Theme.Size.essentialTileHeight)
                        .background(Theme.Palette.tileFill, in: .rect(cornerRadius: Theme.Radius.essentialTile))
                        .reportsRowFrame(for: tab.id)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title.isEmpty ? (tab.url?.host() ?? "") : tab.title)
            }
        }
    }
}
