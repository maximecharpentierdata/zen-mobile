import SwiftUI
import ZenModel
import ZenState

/// Pinned tabs and folders, above the divider (spec §3.2).
struct PinnedSection: View {
    let spaceID: Space.ID
    let items: [PinnedItem]
    let accent: UInt32
    let menus: RowMenus
    let onToggleFolder: @MainActor (Folder.ID) -> Void
    let onOpen: @MainActor (ZenModel.Tab.ID) -> Void

    /// Double-tapping a pinned tab goes back to its pinned URL (spec §3.2).
    private func openPinnedPage(_ id: ZenModel.Tab.ID) {
        menus.goToPinnedURL(id)
        onOpen(id)
    }

    /// The whole section accepts drops, at its end, so a tab can be pinned even when nothing is pinned yet.
    var body: some View {
        Group {
            if items.isEmpty {
                DropPlaceholder(
                    text: "Drag a tab here to pin it",
                    height: Theme.Size.tabRowHeight,
                    cornerRadius: Theme.Radius.tabRow
                )
            } else {
                rows
            }
        }
        .dropsTab(state: menus.state) { .pinned(spaceID, folder: nil, index: .max) }
    }

    private var rows: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.rowGap) {
            ForEach(PinnedRow.rows(for: items)) { row in
                switch row {
                case .folder(let folder, let depth, let tabCount):
                    FolderRow(folder: folder, tabCount: tabCount, accent: accent, depth: depth) {
                        onToggleFolder(folder.id)
                    }
                    .contextMenu { menus.folderMenu(for: folder) }
                    .dropsTab(state: menus.state) { .pinned(spaceID, folder: folder.id, index: .max) }
                case .tab(let tab, let depth):
                    TabRow(tab: tab, accent: accent, depth: depth)
                        .onTap({ onOpen(tab.id) }, doubleTap: { openPinnedPage(tab.id) })
                        .contextMenu { menus.tabMenu(for: tab) }
                        .reorderableTab(tab.id, state: menus.state)
                }
            }
        }
    }
}
