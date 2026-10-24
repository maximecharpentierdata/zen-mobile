import SwiftUI
import ZenModel
import ZenState

/// The spaces side by side; swiping left or right changes space (spec §3.3; design 2A).
///
/// It uses the system's paging scroll view, which follows the finger, commits past half the width or with a
/// flick, rubber-bands at the ends, and keeps vertical scrolling inside a page from changing space.
struct SpacePager: View {
    let state: BrowserState
    let onOpen: @MainActor (ZenModel.Tab.ID) -> Void
    /// Where the pager is between two spaces, for blending their colours.
    @Binding var paging: SpacePaging

    @State private var visibleID: Space.ID?

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(state.data.spaces) { space in
                    SpacePage(
                        space: space,
                        essentials: state.data.essentials,
                        onToggleFolder: { state.toggleFolder($0) },
                        onOpen: { onOpen($0) }
                    )
                    .containerRelativeFrame(.horizontal)
                    .accessibilityHidden(space.id != state.data.currentSpaceID)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $visibleID)
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: SpacePaging.self) { geometry in
            pagingState(geometry)
        } action: { _, newPaging in
            paging = newPaging
        }
        .onAppear { visibleID = state.data.currentSpaceID }
        .onChange(of: visibleID) { _, id in
            if let id, id != state.data.currentSpaceID { state.selectSpace(id) }
        }
        .onChange(of: state.data.currentSpaceID) { _, id in
            guard visibleID != id else { return }
            withAnimation(Motion.changeSpace) { visibleID = id }
        }
    }

    private func pagingState(_ geometry: ScrollGeometry) -> SpacePaging {
        SpacePaging(
            offset: Double(geometry.contentOffset.x),
            pageWidth: Double(geometry.containerSize.width),
            pageCount: state.data.spaces.count
        )
    }
}
