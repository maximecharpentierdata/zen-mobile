import SwiftUI
import ZenModel
import ZenState

/// One space in the pager: its header, the shared Essentials, its pinned section and its regular tabs
/// (spec §3.2; design 1A).
///
/// Essentials sit outside the scrolling list and stay still while the pager slides, because they belong to
/// no space (spec §3.3). The margin is set on each part so the Essentials' slide is measured from the page edge.
struct SpacePage: View {
    let space: Space
    let essentials: [ZenModel.Tab]
    let header: SpaceHeader
    let menus: RowMenus
    /// Whether this is the last space, so the next page is the "New space" page, which has no Essentials.
    let isLast: Bool
    let onToggleFolder: @MainActor (Folder.ID) -> Void
    let onOpen: @MainActor (ZenModel.Tab.ID) -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.section) {
            header
                .padding(.horizontal, Theme.Spacing.screenMargin)
            EssentialsGrid(tabs: essentials, accent: space.accentColor, menus: menus) { onOpen($0) }
                .padding(.horizontal, Theme.Spacing.screenMargin)
                .staysStillWhilePaging(fadesTowardsEnd: isLast)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.section) {
                    PinnedSection(
                        spaceID: space.id,
                        items: space.pinned,
                        accent: space.accentColor,
                        menus: menus,
                        onToggleFolder: { onToggleFolder($0) },
                        onOpen: { onOpen($0) }
                    )
                    divider
                    regularTabs
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, Theme.Spacing.screenMargin)
        }
    }

    /// Dropping a tab on the divider pins it at the end of the pinned section. The drop area is taller than
    /// the line, without changing the layout.
    private var divider: some View {
        Rectangle()
            .fill(Theme.Palette.divider)
            .frame(height: 1)
            .padding(.horizontal, Theme.Spacing.rowPadding)
            .padding(.vertical, Theme.Spacing.dropMargin)
            .contentShape(.rect)
            .dropsTab(state: menus.state) { .pinned(space.id, folder: nil, index: .max) }
            .padding(.vertical, -Theme.Spacing.dropMargin)
            .accessibilityHidden(true)
    }

    private var regularTabs: some View {
        VStack(spacing: Theme.Spacing.rowGap) {
            ForEach(space.regular) { tab in
                Button {
                    onOpen(tab.id)
                } label: {
                    TabRow(tab: tab, accent: space.accentColor)
                }
                .buttonStyle(.plain)
                .contextMenu { menus.tabMenu(for: tab) }
                .reorderableTab(tab.id, state: menus.state)
            }
            Color.clear
                .frame(height: Theme.Size.tabRowHeight)
                .contentShape(.rect)
                .dropsTab(state: menus.state) { .regular(space.id, index: .max) }
                .accessibilityHidden(true)
        }
    }
}
