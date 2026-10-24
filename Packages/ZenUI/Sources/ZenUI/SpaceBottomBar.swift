import SwiftUI

/// The search field and new-tab button at the bottom of the space screen (spec §3.2, §3.6).
/// Both open a new tab with the address field ready.
struct SpaceBottomBar: View {
    let accent: UInt32
    let onNewTab: @MainActor () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.grid) {
            Button(action: onNewTab) {
                HStack(spacing: Theme.Spacing.grid) {
                    Image(systemName: "magnifyingglass")
                    Text("Search or enter address")
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Theme.Palette.secondaryText)
                .padding(.horizontal, Theme.Spacing.section)
                .frame(height: Theme.Size.bottomBarHeight)
                .background(Theme.Palette.fieldFill, in: .capsule)
            }
            Button(action: onNewTab) {
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.Palette.onAccent)
                    .frame(width: Theme.Size.bottomBarHeight, height: Theme.Size.bottomBarHeight)
                    .background(Color(hex: accent), in: .circle)
            }
            .accessibilityLabel(Text("New tab"))
        }
        .buttonStyle(.plain)
    }
}
