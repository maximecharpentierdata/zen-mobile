import SwiftUI
import ZenModel

/// The only control on an open page: the tab's title with its domain underneath (spec §3.4).
/// Tapping it edits the address; dragging it up is the bar gesture (spec §3.5, M4).
struct PageBar: View {
    let tab: ZenModel.Tab
    let onTap: @MainActor () -> Void
    let onShowSpace: @MainActor () -> Void
    let onNewTab: @MainActor () -> Void

    var body: some View {
        Button(action: onTap) {
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
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("Edits the address"))
        .accessibilityAction(named: Text("Back to space")) { onShowSpace() }
        .accessibilityAction(named: Text("New tab")) { onNewTab() }
    }

    private var title: String {
        if !tab.title.isEmpty { return tab.title }
        return tab.url?.host() ?? String(localized: "New tab")
    }
}
