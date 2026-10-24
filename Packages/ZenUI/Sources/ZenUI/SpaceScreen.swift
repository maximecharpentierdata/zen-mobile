import SwiftUI
import ZenModel
import ZenState

/// The full-screen space the app opens on (spec §3.1, §3.2; design 1A).
struct SpaceScreen: View {
    let state: BrowserState

    var body: some View {
        let space = state.data.currentSpace
        VStack(spacing: Theme.Spacing.section) {
            SpaceHeader(space: space)
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.section) {
                    EssentialsGrid(tabs: state.data.essentials, accent: space.accentColor)
                    PinnedSection(items: space.pinned, accent: space.accentColor) { state.toggleFolder($0) }
                    Rectangle()
                        .fill(Theme.Palette.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.rowPadding)
                        .accessibilityHidden(true)
                    ForEach(space.regular) { tab in
                        TabRow(tab: tab, accent: space.accentColor)
                    }
                }
            }
            .scrollIndicators(.hidden)
            SpaceDots(count: state.data.spaces.count, currentIndex: currentIndex, accent: space.accentColor)
            SpaceBottomBar(accent: space.accentColor) { _ = state.newTab() }
        }
        .padding(.horizontal, Theme.Spacing.screenMargin)
        .padding(.vertical, Theme.Spacing.grid)
        .background(Theme.spaceBackground(accent: space.accentColor).ignoresSafeArea())
    }

    private var currentIndex: Int {
        state.data.spaces.firstIndex { $0.id == state.data.currentSpaceID } ?? 0
    }
}
