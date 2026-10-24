import SwiftUI
import ZenModel
import ZenState

extension View {
    /// Lets the user long-press and drag this tab, and drop another tab right before it (spec §3.2).
    func reorderableTab(_ id: ZenModel.Tab.ID, state: BrowserState) -> some View {
        draggable(id.description)
            .dropsTab(state: state, excluding: id) { state.data.destination(before: id) }
    }

    /// Accepts a dragged tab and moves it to `destination`, worked out at drop time (spec §3.2).
    func dropsTab(
        state: BrowserState,
        excluding target: ZenModel.Tab.ID? = nil,
        at destination: @escaping @MainActor () -> TabDestination?
    ) -> some View {
        modifier(TabDropTarget(state: state, target: target, destination: destination))
    }
}

/// Highlights itself while a tab is dragged over it, and moves the tab when it is dropped.
private struct TabDropTarget: ViewModifier {
    let state: BrowserState
    let target: ZenModel.Tab.ID?
    let destination: @MainActor () -> TabDestination?

    @State private var isTargeted = false

    func body(content: Content) -> some View {
        content
            .background(
                isTargeted ? Theme.Palette.tileFill : .clear,
                in: .rect(cornerRadius: Theme.Radius.tabRow)
            )
            .dropDestination(for: String.self) { items, _ in
                drop(items)
            } isTargeted: { targeted in
                isTargeted = targeted
            }
    }

    private func drop(_ items: [String]) -> Bool {
        guard let uuid = items.first.flatMap(UUID.init(uuidString:)) else { return false }
        let id = ZenModel.Tab.ID(uuid)
        guard id != target, state.data.tab(id) != nil, let destination = destination() else { return false }
        state.moveTab(id, to: destination)
        return true
    }
}
