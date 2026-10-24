import SwiftUI

/// A new tab before any address is entered (spec §3.6): only the address field, centred over the dimmed
/// space screen. There is no blank page and no bottom bar until an address loads.
///
/// Tapping anywhere outside the field closes the new tab, so it needs no Cancel button.
struct NewTabOverlay: View {
    let onSubmit: @MainActor (String) -> Void
    let onDismiss: @MainActor () -> Void

    var body: some View {
        ZStack {
            Theme.Palette.scrim
                .ignoresSafeArea()
                .contentShape(.rect)
                .onTapGesture { onDismiss() }
                .accessibilityHidden(true)
            AddressEditor(initialText: "", onSubmit: onSubmit)
                .padding(.horizontal, Theme.Spacing.screenMargin)
        }
        .accessibilityAction(.escape) { onDismiss() }
    }
}
