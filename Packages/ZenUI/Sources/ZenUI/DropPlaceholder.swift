import SwiftUI

/// Stands in for an empty Essentials grid or pinned section, so a dragged tab has somewhere to land
/// (spec §3.2).
struct DropPlaceholder: View {
    let text: LocalizedStringKey
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(Theme.Palette.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Theme.Spacing.rowContent)
            .frame(maxWidth: .infinity, minHeight: height)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Theme.Palette.divider, style: dashed)
            }
            .contentShape(.rect)
    }

    private var dashed: StrokeStyle {
        StrokeStyle(lineWidth: 1, dash: [Theme.Size.placeholderDash])
    }
}
