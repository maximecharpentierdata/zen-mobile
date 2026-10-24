import SwiftUI
import ZenModel
import ZenState

/// The address field with the keyboard open (spec §3.4, §3.6).
///
/// It sits on top of the web page or the dimmed space screen, so its field uses the opaque page bar colour: a
/// translucent fill left light text unreadable on light pages. There is no Cancel button: tapping outside the
/// field closes it.
///
/// While the user types, the field completes the best matching address inline, and matching pages are listed
/// just above the field. The list is an overlay, so it never moves the field.
struct AddressEditor: View {
    let initialText: String
    /// The pages to complete and suggest from, best first.
    let candidates: [ZenModel.Tab]
    let accent: UInt32
    let onSubmit: @MainActor (String) -> Void

    @State private var text = ""
    @State private var selection: TextSelection?
    @State private var typing = AddressTyping(text: "")
    @FocusState private var isFocused: Bool

    private var prompt: Text {
        Text("Search or enter address").foregroundStyle(Theme.Palette.secondaryText)
    }

    /// Nothing is suggested until the user changes the text the field opened with.
    private var suggestions: [ZenModel.Tab] {
        guard typing.typed != initialText else { return [] }
        return AddressAutocomplete.suggestions(for: typing.typed, in: candidates)
    }

    var body: some View {
        TextField(text: $text, selection: $selection, prompt: prompt) {
            Text("Address")
        }
        .focused($isFocused)
        .keyboardType(.webSearch)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .submitLabel(.go)
        .onSubmit { onSubmit(text) }
        .onChange(of: text) { _, newText in showCompletion(after: newText) }
        .foregroundStyle(Theme.Palette.primaryText)
        .padding(.horizontal, Theme.Spacing.section)
        .frame(height: Theme.Size.bottomBarHeight)
        .background(Theme.Palette.pageBarFill, in: .capsule)
        .contentShape(.capsule)
        .overlay(alignment: .top) {
            if !suggestions.isEmpty {
                AddressSuggestionList(suggestions: suggestions, accent: accent, onSelect: select)
                    .alignmentGuide(.top) { $0[.bottom] + Theme.Spacing.grid }
            }
        }
        .onAppear {
            typing = AddressTyping(text: initialText)
            text = initialText
            isFocused = true
        }
    }

    /// Writes the inline completion into the field and selects it, so the next key replaces it.
    private func showCompletion(after newText: String) {
        guard typing.fieldChanged(to: newText, candidates: candidates) else { return }
        text = typing.shown
        selection = typing.completionRange.map { TextSelection(range: $0) }
    }

    private func select(_ tab: ZenModel.Tab) {
        guard let url = tab.url else { return }
        onSubmit(url.absoluteString)
    }
}
