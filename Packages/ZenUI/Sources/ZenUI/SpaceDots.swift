import SwiftUI

/// One dot per space; the current one is wider and in the space's colour (spec §3.2).
struct SpaceDots: View {
    let count: Int
    let currentIndex: Int
    let accent: UInt32

    var body: some View {
        HStack(spacing: Theme.Spacing.dots) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color(hex: accent) : Theme.Palette.inactiveDot)
                    .frame(
                        width: index == currentIndex ? Theme.Size.currentDotWidth : Theme.Size.dot,
                        height: Theme.Size.dot
                    )
            }
        }
        .accessibilityElement()
        .accessibilityLabel(Text("Space \(currentIndex + 1) of \(count)"))
    }
}
