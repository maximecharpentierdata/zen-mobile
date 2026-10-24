import Foundation
import ZenModel

/// Space management: create, edit, reorder and delete (spec §3.7).
extension BrowserState {
    /// Creates a space after the existing ones, shows it, and returns its id. Returns `nil` when `name` is
    /// blank. A blank `icon` becomes the name's first letter (see ``SpaceForm``).
    @discardableResult
    public func createSpace(name: String, icon: String, accentColor: UInt32) -> Space.ID? {
        guard let form = SpaceForm(name: name, icon: icon) else { return nil }
        var id: Space.ID?
        perform { data in
            let newID = data.addSpace(name: form.name, icon: form.icon, accentColor: accentColor)
            try data.selectSpace(newID)
            id = newID
        }
        return id
    }

    /// Changes a space's name, icon and colour. Does nothing when `name` is blank.
    public func editSpace(_ id: Space.ID, name: String, icon: String, accentColor: UInt32) {
        guard let form = SpaceForm(name: name, icon: icon) else { return }
        perform { try $0.editSpace(id, name: form.name, icon: form.icon, accentColor: accentColor) }
    }

    /// Moves a space `step` places right, or left when `step` is negative, within the bounds.
    public func moveSpace(_ id: Space.ID, step: Int) {
        guard let index = data.spaces.firstIndex(where: { $0.id == id }) else { return }
        perform { try $0.moveSpace(id, to: index + step) }
    }

    /// Whether a space can move `step` places without leaving the bounds.
    public func canMoveSpace(_ id: Space.ID, step: Int) -> Bool {
        guard let index = data.spaces.firstIndex(where: { $0.id == id }) else { return false }
        return data.spaces.indices.contains(index + step)
    }

    /// Deletes a space, closing its tabs or moving them to another space. The last space can't be deleted.
    public func deleteSpace(_ id: Space.ID, tabs: BrowserData.DeletedSpaceTabs) {
        perform { try $0.deleteSpace(id, tabs: tabs) }
    }
}
