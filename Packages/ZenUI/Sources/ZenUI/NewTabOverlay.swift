import SwiftUI
import ZenModel

/// A new tab before any address is entered (spec §3.6): only the address field, centred over the dimmed
/// space screen. There is no blank page and no bottom bar until an address loads. The field is the space
/// screen's search field moved up, so there is never a second one at the bottom.
///
/// Tapping anywhere outside the field closes the new tab, so it needs no Cancel button.
struct NewTabOverlay: View {
    /// The pages the address field completes and suggests from.
    let candidates: [ZenModel.Tab]
    let accent: UInt32
    /// Shared with the space screen's search field; `nil` with Reduce Motion.
    let fieldNamespace: Namespace.ID?
    let onSubmit: @MainActor (String) -> Void
    let onDismiss: @MainActor () -> Void

    var body: some View {
        ZStack {
            Theme.Palette.scrim
                .ignoresSafeArea()
                .contentShape(.rect)
                .onTapGesture { onDismiss() }
                .accessibilityHidden(true)
            AddressEditor(initialText: "", candidates: candidates, accent: accent, onSubmit: onSubmit)
                .modifier(AddressFieldMatch(namespace: fieldNamespace))
                .padding(.horizontal, Theme.Spacing.screenMargin)
        }
        .accessibilityAction(.escape) { onDismiss() }
    }
}
