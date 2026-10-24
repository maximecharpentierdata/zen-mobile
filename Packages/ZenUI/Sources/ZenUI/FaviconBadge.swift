import SwiftUI
import ZenModel

/// A tab's icon. Until favicons load (M3), it shows the first letter of the title or host on the accent colour.
struct FaviconBadge: View {
    let tab: Tab
    let accent: UInt32
    let size: CGFloat

    var body: some View {
        Text(initial)
            .font(.system(size: size * 0.5, weight: .bold))
            .foregroundStyle(Theme.Palette.onAccent)
            .frame(width: size, height: size)
            .background(Color(hex: accent), in: .rect(cornerRadius: Theme.Radius.favicon))
            .accessibilityHidden(true)
    }

    private var initial: String {
        let source = tab.title.isEmpty ? (tab.url?.host() ?? "") : tab.title
        return source.first.map { String($0).uppercased() } ?? "•"
    }
}
