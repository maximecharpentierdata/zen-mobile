import SwiftUI

/// The address field with the keyboard open (spec §3.4, §3.6).
///
/// It sits on top of the web page, so its field and button use the opaque page bar colour: a translucent fill
/// left light text unreadable on light pages.
struct AddressEditor: View {
    let initialText: String
    let onSubmit: @MainActor (String) -> Void
    let onCancel: @MainActor () -> Void

    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.grid) {
            TextField(text: $text, prompt: Text("Search or enter address")) {
                Text("Address")
            }
            .focused($isFocused)
            .keyboardType(.webSearch)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.go)
            .onSubmit { onSubmit(text) }
            .foregroundStyle(Theme.Palette.primaryText)
            .padding(.horizontal, Theme.Spacing.section)
            .frame(height: Theme.Size.bottomBarHeight)
            .background(Theme.Palette.pageBarFill, in: .capsule)
            Button("Cancel", action: onCancel)
                .foregroundStyle(Theme.Palette.primaryText)
                .padding(.horizontal, Theme.Spacing.section)
                .frame(height: Theme.Size.bottomBarHeight)
                .background(Theme.Palette.pageBarFill, in: .capsule)
        }
        .onAppear {
            text = initialText
            isFocused = true
        }
    }
}
