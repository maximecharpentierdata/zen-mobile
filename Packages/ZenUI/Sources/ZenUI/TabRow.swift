import SwiftUI
import ZenModel

/// A tab in the space list (spec §3.2).
struct TabRow: View {
    let tab: ZenModel.Tab
    let accent: UInt32
    var depth = 0

    var body: some View {
        HStack(spacing: Theme.Spacing.rowContent) {
            FaviconBadge(tab: tab, accent: accent, size: Theme.Size.favicon)
            Text(title)
                .font(.body)
                .foregroundStyle(Theme.Palette.primaryText)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.leading, Theme.Spacing.rowPadding + CGFloat(depth) * Theme.Spacing.indentPerLevel)
        .padding(.trailing, Theme.Spacing.rowPadding)
        .frame(minHeight: Theme.Size.tabRowHeight)
        .contentShape(.rect(cornerRadius: Theme.Radius.tabRow))
    }

    private var title: String {
        if !tab.title.isEmpty { return tab.title }
        return tab.url?.host() ?? String(localized: "New tab")
    }
}
