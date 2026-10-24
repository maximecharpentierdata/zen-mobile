import SwiftUI
import ZenModel

/// The pages that match what is typed in the address field, best first (spec §3.4, §3.6). Tapping one loads
/// its address, as if it had been typed.
struct AddressSuggestionList: View {
    let suggestions: [ZenModel.Tab]
    let accent: UInt32
    let onSelect: @MainActor (ZenModel.Tab) -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.rowGap) {
            ForEach(suggestions) { tab in
                Button {
                    onSelect(tab)
                } label: {
                    AddressSuggestionRow(tab: tab, accent: accent)
                }
                .buttonStyle(.plain)
                .accessibilityHint(Text("Opens this page"))
            }
        }
        .padding(.vertical, Theme.Spacing.rowGap)
        .background(Theme.Palette.pageBarFill, in: .rect(cornerRadius: Theme.Radius.tabRow))
    }
}
