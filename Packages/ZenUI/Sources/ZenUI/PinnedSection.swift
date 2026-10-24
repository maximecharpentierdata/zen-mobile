import SwiftUI
import ZenModel
import ZenState

/// Pinned tabs and folders, above the divider (spec §3.2).
struct PinnedSection: View {
    let items: [PinnedItem]
    let accent: UInt32
    let onToggleFolder: @MainActor (Folder.ID) -> Void
    let onOpen: @MainActor (ZenModel.Tab.ID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.rowGap) {
            ForEach(PinnedRow.rows(for: items)) { row in
                switch row {
                case .folder(let folder, let depth, let tabCount):
                    FolderRow(folder: folder, tabCount: tabCount, accent: accent, depth: depth) {
                        onToggleFolder(folder.id)
                    }
                case .tab(let tab, let depth):
                    Button {
                        onOpen(tab.id)
                    } label: {
                        TabRow(tab: tab, accent: accent, depth: depth)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
