import SwiftUI
import ZenModel

/// A folder in the pinned section. Tapping it expands or collapses it (spec §3.2).
struct FolderRow: View {
    let folder: Folder
    let tabCount: Int
    let accent: UInt32
    var depth = 0
    let onToggle: @MainActor () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: Theme.Spacing.rowContent) {
                Image(systemName: folder.isExpanded ? "chevron.down" : "chevron.right")
                    .foregroundStyle(Theme.Palette.secondaryText)
                    .frame(width: Theme.Size.favicon)
                Image(systemName: "folder")
                    .foregroundStyle(Color(hex: accent))
                Text(folder.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.Palette.primaryText)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if !folder.isExpanded {
                    Text(tabCount, format: .number)
                        .font(.subheadline)
                        .foregroundStyle(Theme.Palette.secondaryText)
                }
            }
            .padding(.leading, Theme.Spacing.rowPadding + CGFloat(depth) * Theme.Spacing.indentPerLevel)
            .padding(.trailing, Theme.Spacing.rowPadding)
            .frame(minHeight: Theme.Size.tabRowHeight)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(folder.name)
        .accessibilityValue(folder.isExpanded ? Text("Expanded") : Text("\(tabCount) tabs, collapsed"))
    }
}
