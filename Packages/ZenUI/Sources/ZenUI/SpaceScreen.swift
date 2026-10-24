import SwiftUI
import ZenModel
import ZenState

/// The full-screen space the app opens on (spec §3.1, §3.2; design 1A), with the pager that changes space
/// (spec §3.3; design 2A).
struct SpaceScreen: View {
    let state: BrowserState
    let onOpen: @MainActor (ZenModel.Tab.ID) -> Void
    let onNewTab: @MainActor () -> Void

    @State private var paging = SpacePaging(offset: 0, pageWidth: 0, pageCount: 0)

    var body: some View {
        VStack(spacing: Theme.Spacing.section) {
            SpacePager(state: state, onOpen: onOpen, paging: $paging)
            Group {
                SpaceDots(
                    count: state.data.spaces.count,
                    currentIndex: paging.nearestIndex,
                    accent: accent,
                    onStep: { state.selectSpace(step: $0) }
                )
                SpaceBottomBar(accent: accent) { onNewTab() }
            }
            .padding(.horizontal, Theme.Spacing.screenMargin)
        }
        .padding(.vertical, Theme.Spacing.grid)
        .background(Theme.spaceBackground(accent: accent).ignoresSafeArea())
    }

    /// The accent colour, blended between the two spaces while swiping.
    private var accent: UInt32 {
        let spaces = state.data.spaces
        guard spaces.indices.contains(paging.from), spaces.indices.contains(paging.to) else {
            return state.data.currentSpace.accentColor
        }
        return Color.mix(spaces[paging.from].accentColor, spaces[paging.to].accentColor, amount: paging.fraction)
    }
}
