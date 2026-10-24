import SwiftUI
import ZenModel
import ZenState

/// A request to type a name: a new folder for a tab, an empty new folder, or a folder's new name (spec §3.2).
enum NamePrompt: Identifiable {
    case newFolder(for: ZenModel.Tab.ID)
    case emptyFolder(in: Space.ID)
    case renameFolder(Folder)

    var id: String {
        switch self {
        case .newFolder(let tabID): "new-\(tabID)"
        case .emptyFolder(let spaceID): "empty-\(spaceID)"
        case .renameFolder(let folder): "rename-\(folder.id)"
        }
    }
}

/// Shows a ``NamePrompt`` as an alert with a text field, and applies the name.
struct NamePromptAlert: ViewModifier {
    let state: BrowserState
    @Binding var prompt: NamePrompt?
    @State private var name = ""

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: isPresented, presenting: prompt) { prompt in
                TextField("Name", text: $name)
                Button("Cancel", role: .cancel) {}
                Button("Save") { apply(prompt) }
            }
            .onChange(of: prompt?.id) {
                if case .renameFolder(let folder) = prompt {
                    name = folder.name
                } else {
                    name = ""
                }
            }
    }

    private var title: Text {
        if case .renameFolder = prompt {
            return Text("Rename folder")
        }
        return Text("New folder")
    }

    private var isPresented: Binding<Bool> {
        Binding(get: { prompt != nil }, set: { if !$0 { prompt = nil } })
    }

    private func apply(_ prompt: NamePrompt) {
        switch prompt {
        case .newFolder(let tabID):
            state.moveTabToNewFolder(tabID, named: name)
        case .emptyFolder(let spaceID):
            state.createFolder(named: name, in: spaceID)
        case .renameFolder(let folder):
            state.renameFolder(folder.id, to: name)
        }
    }
}
