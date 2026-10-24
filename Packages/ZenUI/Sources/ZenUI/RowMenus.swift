import SwiftUI
import ZenModel
import ZenState

/// The long-press menus of tab and folder rows (spec §3.2).
@MainActor
struct RowMenus {
    let state: BrowserState
    let onPrompt: @MainActor (NamePrompt) -> Void

    /// The menu of a tab, which depends on where the tab is.
    @ViewBuilder
    func tabMenu(for tab: ZenModel.Tab) -> some View {
        switch state.data.location(of: tab.id) {
        case .regular(let spaceID):
            Button("Pin", systemImage: "pin") { state.pin(tab.id) }
            spaceTabItems(for: tab, in: spaceID)
        case .pinned(let spaceID, _):
            Button("Unpin", systemImage: "pin.slash") { state.unpin(tab.id) }
            spaceTabItems(for: tab, in: spaceID)
        case .essentials:
            Button("Remove from Essentials", systemImage: "star.slash") { state.removeFromEssentials(tab.id) }
            commonItems(for: tab)
        case nil:
            EmptyView()
        }
    }

    /// The menu of a folder.
    @ViewBuilder
    func folderMenu(for folder: Folder) -> some View {
        Button("Rename", systemImage: "pencil") { onPrompt(.renameFolder(folder)) }
        Button("Delete folder", systemImage: "folder.badge.minus", role: .destructive) {
            state.deleteFolder(folder.id)
        }
    }

    @ViewBuilder
    private func spaceTabItems(for tab: ZenModel.Tab, in spaceID: Space.ID) -> some View {
        moveToFolderMenu(for: tab, in: spaceID)
        moveToSpaceMenu(for: tab, from: spaceID)
        Button("Add to Essentials", systemImage: "star") { state.addToEssentials(tab.id) }
        commonItems(for: tab)
    }

    @ViewBuilder
    private func commonItems(for tab: ZenModel.Tab) -> some View {
        Button("Duplicate", systemImage: "plus.square.on.square") { state.duplicateTab(tab.id) }
        Button("Close", systemImage: "xmark", role: .destructive) { state.closeTab(tab.id) }
    }

    private func moveToFolderMenu(for tab: ZenModel.Tab, in spaceID: Space.ID) -> some View {
        let folders = PinnedRow.allFolders(in: state.data.space(spaceID)?.pinned ?? [])
        return Menu("Move to folder", systemImage: "folder") {
            ForEach(folders) { folder in
                Button(folder.name) { state.moveTab(tab.id, toFolder: folder.id) }
            }
            Button("New folder…", systemImage: "folder.badge.plus") { onPrompt(.newFolder(for: tab.id)) }
        }
    }

    @ViewBuilder
    private func moveToSpaceMenu(for tab: ZenModel.Tab, from spaceID: Space.ID) -> some View {
        let others = state.data.spaces.filter { $0.id != spaceID }
        if !others.isEmpty {
            Menu("Move to space", systemImage: "rectangle.stack") {
                ForEach(others) { space in
                    Button("\(space.icon) \(space.name)") { state.moveTab(tab.id, toSpace: space.id) }
                }
            }
        }
    }
}
