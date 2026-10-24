import SwiftUI

/// The search field at the bottom of the space screen (spec §3.2, §3.6).
/// It opens a new tab with the address field ready.
struct SpaceBottomBar: View {
    let onNewTab: @MainActor () -> Void

    var body: some View {
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
        .buttonStyle(.plain)
    }
}
