import SwiftUI
import ZenModel

/// A tab's icon: the page's favicon once it is known and loaded. Before that, or when it can't be loaded,
/// it shows the first letter of the title or host on the accent colour.
struct FaviconBadge: View {
    let tab: ZenModel.Tab
    let accent: UInt32
    let size: CGFloat

    var body: some View {
        if let faviconURL = tab.faviconURL {
            AsyncImage(url: faviconURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .clipShape(.rect(cornerRadius: Theme.Radius.favicon))
                        .accessibilityHidden(true)
                } else {
                    letter
                }
            }
        } else {
            letter
        }
    }

    private var letter: some View {
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
