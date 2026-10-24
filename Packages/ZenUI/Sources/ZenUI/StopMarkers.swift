import SwiftUI
import ZenState

/// The two stops shown while dragging the page bar up: "Space", then "New tab" (spec §3.5; design 4A).
struct StopMarkers: View {
    let stage: BarGesture.Outcome
    let accent: UInt32

    var body: some View {
        VStack(alignment: .trailing, spacing: Theme.Spacing.section) {
            marker(Text("New tab"), systemImage: "plus", isActive: stage == .newTab)
            marker(Text("Space"), systemImage: "square.stack", isActive: stage == .showSpace)
        }
        .accessibilityHidden(true)
    }

    private func marker(_ title: Text, systemImage: String, isActive: Bool) -> some View {
        Label { title } icon: { Image(systemName: systemImage) }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isActive ? Theme.Palette.onAccent : Theme.Palette.primaryText)
            .padding(.horizontal, Theme.Spacing.rowContent)
            .frame(height: Theme.Size.stopMarkerHeight)
            .background(isActive ? Color(hex: accent) : Theme.Palette.fieldFill, in: .capsule)
    }
}
