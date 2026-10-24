import SwiftUI
import ZenModel
import ZenState

/// Presents the space editor and the delete confirmation, and runs the space options menu's actions
/// (spec §3.7).
struct SpaceManagement: ViewModifier {
    let state: BrowserState
    @Binding var editor: SpaceEditor.Target?
    @Binding var deleting: Space?

    func body(content: Content) -> some View {
        content
            .sheet(item: $editor) { target in
                SpaceEditor(target: target) { name, icon, accent in
                    save(target, name: name, icon: icon, accent: accent)
                }
            }
            .confirmationDialog(
                deleteTitle,
                isPresented: isDeleting,
                titleVisibility: .visible,
                presenting: deleting
            ) { space in
                deleteButtons(for: space)
            } message: { _ in
                Text("Its tabs can be closed or moved to another space.")
            }
    }

    private var deleteTitle: Text {
        Text("Delete “\(deleting?.name ?? "")”?")
    }

    private var isDeleting: Binding<Bool> {
        Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })
    }

    @ViewBuilder private func deleteButtons(for space: Space) -> some View {
        Button("Delete and close its tabs", role: .destructive) {
            state.deleteSpace(space.id, tabs: .close)
        }
        ForEach(state.data.spaces.filter { $0.id != space.id }) { other in
            Button("Delete and move tabs to \(other.name)") {
                state.deleteSpace(space.id, tabs: .moveTo(other.id))
            }
        }
        Button("Cancel", role: .cancel) {}
    }

    private func save(_ target: SpaceEditor.Target, name: String, icon: String, accent: UInt32) {
        switch target {
        case .new:
            state.createSpace(name: name, icon: icon, accentColor: accent)
        case .edit(let space):
            state.editSpace(space.id, name: name, icon: icon, accentColor: accent)
        }
    }
}

extension SpaceManagement {
    /// Runs one of the options menu's actions, opening the editor or the confirmation when needed.
    @MainActor
    static func handle(
        _ action: SpaceAction,
        state: BrowserState,
        editor: inout SpaceEditor.Target?,
        deleting: inout Space?
    ) {
        let spaces = state.data.spaces
        switch action {
        case .edit(let id):
            if let space = spaces.first(where: { $0.id == id }) { editor = .edit(space) }
        case .newSpace:
            editor = .new(accent: Theme.Palette.newSpaceAccent(after: spaces.count))
        case .moveLeft(let id):
            state.moveSpace(id, step: -1)
        case .moveRight(let id):
            state.moveSpace(id, step: 1)
        case .delete(let id):
            deleting = spaces.first { $0.id == id }
        }
    }
}
