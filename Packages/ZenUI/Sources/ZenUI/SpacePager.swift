import SwiftUI
import ZenModel
import ZenState

/// The spaces side by side; swiping left or right changes space (spec §3.3; design 2A).
///
/// It uses the system's paging scroll view, which follows the finger, commits past half the width or with a
/// flick, rubber-bands at the ends, and keeps vertical scrolling inside a page from changing space.
/// After the last space comes the "New space" page: settling on it opens the new space sheet, and closing the
/// sheet without creating the space swipes back.
struct SpacePager: View {
    let state: BrowserState
    let onOpen: @MainActor (ZenModel.Tab.ID) -> Void
    let onAction: @MainActor (SpaceAction) -> Void
    let menus: RowMenus
    /// Whether the space sheet is open. When it closes on the "New space" page, the pager goes back.
    let isEditing: Bool
    /// Where the pager is between two spaces, for blending their colours.
    @Binding var paging: SpacePaging

    @State private var position = ScrollPosition(idType: Space.ID.self)

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(state.data.spaces) { space in
                    SpacePage(
                        space: space,
                        essentials: state.data.essentials,
                        header: header(for: space),
                        menus: menus,
                        isLast: space.id == state.data.spaces.last?.id,
                        onToggleFolder: { state.toggleFolder($0) },
                        onOpen: { onOpen($0) }
                    )
                    .containerRelativeFrame(.horizontal)
                    .accessibilityHidden(space.id != state.data.currentSpaceID)
                }
                NewSpacePage { onAction(.newSpace) }
                    .containerRelativeFrame(.horizontal)
                    .accessibilityHidden(true)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition($position)
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: SpacePaging.self) { geometry in
            pagingState(geometry)
        } action: { _, newPaging in
            paging = newPaging
        }
        .onScrollPhaseChange { _, phase in
            if phase == .idle, isOnNewSpacePage { onAction(.newSpace) }
        }
        .onAppear { position.scrollTo(id: state.data.currentSpaceID) }
        .onChange(of: position.viewID(type: Space.ID.self)) { _, id in
            if let id, id != state.data.currentSpaceID { state.selectSpace(id) }
        }
        .onChange(of: state.data.currentSpaceID) { _, id in
            guard position.viewID(type: Space.ID.self) != id else { return }
            withAnimation(Motion.changeSpace) { position.scrollTo(id: id) }
        }
        .onChange(of: isEditing) { _, editing in
            guard !editing, isOnNewSpacePage else { return }
            withAnimation(Motion.changeSpace) { position.scrollTo(id: state.data.currentSpaceID) }
        }
    }

    private var isOnNewSpacePage: Bool {
        paging.nearestIndex >= state.data.spaces.count
    }

    private func pagingState(_ geometry: ScrollGeometry) -> SpacePaging {
        SpacePaging(
            offset: Double(geometry.contentOffset.x),
            pageWidth: Double(geometry.containerSize.width),
            pageCount: state.data.spaces.count + 1
        )
    }

    private func header(for space: Space) -> SpaceHeader {
        SpaceHeader(
            space: space,
            canMoveLeft: state.canMoveSpace(space.id, step: -1),
            canMoveRight: state.canMoveSpace(space.id, step: 1),
            canDelete: state.data.spaces.count > 1,
            hasRecentlyClosed: !state.data.recentlyClosed.isEmpty,
            autoCloseDelay: state.data.autoCloseDelay,
            onAction: { onAction($0) }
        )
    }
}
