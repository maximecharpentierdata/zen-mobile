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

    var body: some View {
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
                    Button {
                        onOpen(tab.id)
                    } label: {
                        TabRow(tab: tab, accent: accent, depth: depth)
                    }
                    .buttonStyle(.plain)
                    .contextMenu { menus.tabMenu(for: tab) }
                    .reorderableTab(tab.id, state: menus.state)
                }
            }
        }
    }
}
