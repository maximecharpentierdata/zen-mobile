import SwiftUI
import ZenModel
import ZenState

/// The sheet that creates a space or edits its name, icon and colour (spec §3.7).
struct SpaceEditor: View {
    /// What the sheet is for.
    enum Target: Identifiable {
        /// A new space, starting with this colour.
        case new(accent: UInt32)
        case edit(Space)

        var id: String {
            switch self {
            case .new: "new"
            case .edit(let space): space.id.description
            }
        }
    }

    let target: Target
    let onSave: @MainActor (_ name: String, _ icon: String, _ accent: UInt32) -> Void

    @State private var name: String
    @State private var icon: String
    @State private var color: Color
    @Environment(\.dismiss) private var dismiss

    init(target: Target, onSave: @escaping @MainActor (_ name: String, _ icon: String, _ accent: UInt32) -> Void) {
        self.target = target
        self.onSave = onSave
        switch target {
        case .new(let accent):
            _name = State(initialValue: "")
            _icon = State(initialValue: "")
            _color = State(initialValue: Color(hex: accent))
        case .edit(let space):
            _name = State(initialValue: space.name)
            _icon = State(initialValue: space.icon)
            _color = State(initialValue: Color(hex: space.accentColor))
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Icon (an emoji or a letter)", text: $icon)
                ColorPicker("Colour", selection: $color, supportsOpacity: false)
            }
            .navigationTitle(isNew ? Text("New space") : Text("Edit space"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
        }
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button {
                onSave(name, icon, color.hexValue)
                dismiss()
            } label: {
                isNew ? Text("Create") : Text("Save")
            }
            .disabled(SpaceForm(name: name, icon: icon) == nil)
        }
    }

    private var isNew: Bool {
        if case .new = target { true } else { false }
    }
}
