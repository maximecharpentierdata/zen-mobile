import SwiftUI

/// The address field with the keyboard open (spec §3.4, §3.6).
///
/// It sits on top of the web page or the dimmed space screen, so its field uses the opaque page bar colour: a
/// translucent fill left light text unreadable on light pages. There is no Cancel button: tapping outside the
/// field closes it.
struct AddressEditor: View {
    let initialText: String
    let onSubmit: @MainActor (String) -> Void

    @State private var text = ""
    @FocusState private var isFocused: Bool

    private var prompt: Text {
        Text("Search or enter address").foregroundStyle(Theme.Palette.secondaryText)
    }

    var body: some View {
        TextField(text: $text, prompt: prompt) {
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
        .contentShape(.capsule)
        .onAppear {
            text = initialText
            isFocused = true
        }
    }
}
