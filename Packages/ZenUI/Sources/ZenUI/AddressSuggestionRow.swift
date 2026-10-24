import SwiftUI
import ZenModel

/// One suggested page: its icon, its title and its address, like the page bar's title and domain.
struct AddressSuggestionRow: View {
    let tab: ZenModel.Tab
    let accent: UInt32

    var body: some View {
        HStack(spacing: Theme.Spacing.rowContent) {
            FaviconBadge(tab: tab, accent: accent, size: Theme.Size.favicon)
            VStack(alignment: .leading, spacing: 0) {
                if !tab.title.isEmpty {
                    Text(tab.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.Palette.primaryText)
                        .lineLimit(1)
                }
                Text(address)
                    .font(.caption)
                    .foregroundStyle(Theme.Palette.secondaryText)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Theme.Spacing.rowPadding)
        .frame(minHeight: Theme.Size.tabRowHeight)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    private var address: String {
        tab.url.map(AddressAutocomplete.displayAddress(of:)) ?? ""
    }
}
