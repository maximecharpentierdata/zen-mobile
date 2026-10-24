import SwiftUI

/// The page after the last space: swiping past the last space shows it (spec §3.3).
struct NewSpacePage: View {
    let onNewSpace: @MainActor () -> Void

    var body: some View {
        Button(action: onNewSpace) {
            VStack(spacing: Theme.Spacing.grid) {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.Palette.onAccent)
                    .frame(width: Theme.Size.bottomBarHeight, height: Theme.Size.bottomBarHeight)
                    .background(Theme.Palette.primaryText, in: .circle)
                Text("New space")
                    .font(.headline)
                    .foregroundStyle(Theme.Palette.primaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
