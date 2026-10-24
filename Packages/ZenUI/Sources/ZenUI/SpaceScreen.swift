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
    @State private var editor: SpaceEditor.Target?
    @State private var deleting: Space?

    var body: some View {
        VStack(spacing: Theme.Spacing.section) {
            SpacePager(state: state, onOpen: onOpen, onAction: handle, paging: $paging)
            Group {
                SpaceDots(
                    count: state.data.spaces.count,
                    currentIndex: min(paging.nearestIndex, state.data.spaces.count - 1),
                    accent: accent,
                    onStep: { state.selectSpace(step: $0) }
                )
                SpaceBottomBar(accent: accent) { onNewTab() }
            }
            .padding(.horizontal, Theme.Spacing.screenMargin)
        }
        .padding(.vertical, Theme.Spacing.grid)
        .background(Theme.spaceBackground(accent: accent).ignoresSafeArea())
        .modifier(SpaceManagement(state: state, editor: $editor, deleting: $deleting))
    }

    private func handle(_ action: SpaceAction) {
        SpaceManagement.handle(action, state: state, editor: &editor, deleting: &deleting)
    }

    /// The accent colour, blended between the two spaces while swiping. The "New space" page keeps the last
    /// space's colour.
    private var accent: UInt32 {
        let spaces = state.data.spaces
        let lastIndex = spaces.count - 1
        let from = spaces[min(paging.from, lastIndex)].accentColor
        let to = spaces[min(paging.to, lastIndex)].accentColor
        return Color.mix(from, to, amount: paging.fraction)
    }
}
