import SwiftUI
import ZenModel
import ZenState

/// One space in the pager: its header, the shared Essentials, its pinned section and its regular tabs
/// (spec §3.2; design 1A).
struct SpacePage: View {
    let space: Space
    let essentials: [ZenModel.Tab]
    let onToggleFolder: @MainActor (Folder.ID) -> Void
    let onOpen: @MainActor (ZenModel.Tab.ID) -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.section) {
            SpaceHeader(space: space)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.section) {
                    EssentialsGrid(tabs: essentials, accent: space.accentColor) { onOpen($0) }
                    PinnedSection(
                        items: space.pinned,
                        accent: space.accentColor,
                        onToggleFolder: { onToggleFolder($0) },
                        onOpen: { onOpen($0) }
                    )
                    Rectangle()
                        .fill(Theme.Palette.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.rowPadding)
                        .accessibilityHidden(true)
                    regularTabs
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, Theme.Spacing.screenMargin)
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
            }
        }
    }
}
