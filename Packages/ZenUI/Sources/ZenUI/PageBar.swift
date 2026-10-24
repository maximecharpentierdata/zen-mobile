import SwiftUI
import ZenModel

/// The only control on an open page: the tab's title with its domain underneath (spec §3.4).
/// Tapping it edits the address; dragging it up is the bar gesture (spec §3.5).
struct PageBar: View {
    let tab: ZenModel.Tab
    let onTap: @MainActor () -> Void
    /// Set for pinned tabs and Essentials: a double tap goes back to the pinned URL (spec §3.4).
    let onDoubleTap: (@MainActor () -> Void)?
    let onShowSpace: @MainActor () -> Void
    let onNewTab: @MainActor () -> Void
    /// The finger moved: upward distance in points.
    let onDrag: @MainActor (CGFloat) -> Void
    /// The finger lifted: upward distance and upward speed in points per second.
    let onRelease: @MainActor (CGFloat, CGFloat) -> Void

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.Palette.primaryText)
                .lineLimit(1)
            if let host = tab.url?.host() {
                Text(host)
                    .font(.caption)
                    .foregroundStyle(Theme.Palette.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, Theme.Spacing.section)
        .frame(maxWidth: .infinity, minHeight: Theme.Size.pageBarHeight)
        .background(Theme.Palette.pageBarFill, in: .capsule)
        .onTap(onTap, doubleTap: onDoubleTap)
        .gesture(
            DragGesture(minimumDistance: GestureMetrics.barDragMinimumDistance, coordinateSpace: .global)
                .onChanged { value in onDrag(-value.translation.height) }
                .onEnded { value in onRelease(-value.translation.height, -value.velocity.height) }
        )
        .accessibilityHint(Text("Edits the address"))
        .accessibilityAction(named: Text("Back to space")) { onShowSpace() }
        .accessibilityAction(named: Text("New tab")) { onNewTab() }
    }

    private var title: String {
        if !tab.title.isEmpty { return tab.title }
        return tab.url?.host() ?? String(localized: "New tab")
    }
}
