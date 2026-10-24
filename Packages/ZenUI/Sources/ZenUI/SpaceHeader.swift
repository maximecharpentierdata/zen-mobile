import SwiftUI
import ZenModel

/// The space's icon and name at the top of the space screen (spec §3.2).
struct SpaceHeader: View {
    let space: Space

    var body: some View {
        HStack(spacing: Theme.Spacing.rowPadding) {
            Text(space.icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.Palette.onAccent)
                .frame(width: Theme.Size.headerIcon, height: Theme.Size.headerIcon)
                .background(Color(hex: space.accentColor), in: .rect(cornerRadius: Theme.Radius.headerIcon))
                .accessibilityHidden(true)
            Text(space.name)
                .font(.title2.bold())
                .foregroundStyle(Theme.Palette.primaryText)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
