import SwiftUI

/// Colours, spacing and radii from `docs/design.md`. Views take visual constants from here only.
enum Theme {
    /// Colours shared by every space.
    enum Palette {
        static var primaryText: Color { Color(hex: 0xF3F2F8) }
        static var secondaryText: Color { Color(hex: 0xABA8BE) }
        /// Text on top of a space's accent colour.
        static var onAccent: Color { Color(hex: 0x141218) }
        static var tileFill: Color { .white.opacity(0.08) }
        static var fieldFill: Color { .white.opacity(0.10) }
        static var divider: Color { .white.opacity(0.12) }
        static var inactiveDot: Color { .white.opacity(0.30) }
        /// The near-black that space backgrounds are tinted from.
        static var backgroundBase: UInt32 { 0x121216 }
    }

    /// Spacing in points.
    enum Spacing {
        static let screenMargin: CGFloat = 16
        static let section: CGFloat = 18
        static let rowPadding: CGFloat = 10
        static let rowContent: CGFloat = 12
        static let grid: CGFloat = 10
        static let indentPerLevel: CGFloat = 32
        static let dots: CGFloat = 8
    }

    /// Corner radii in points.
    enum Radius {
        static let tabRow: CGFloat = 12
        static let essentialTile: CGFloat = 16
        static let headerIcon: CGFloat = 10
        static let favicon: CGFloat = 6
    }

    /// Fixed sizes in points.
    enum Size {
        static let tabRowHeight: CGFloat = 44
        static let essentialTileHeight: CGFloat = 60
        static let bottomBarHeight: CGFloat = 50
        static let headerIcon: CGFloat = 32
        static let favicon: CGFloat = 20
        static let essentialIcon: CGFloat = 28
        static let dot: CGFloat = 6
        static let currentDotWidth: CGFloat = 18
    }

    /// The share of the accent colour mixed into a space's background (design.md: dark, tinted backgrounds).
    static let backgroundTint = 0.10
    /// Columns in the Essentials grid (spec §3.2).
    static let essentialsColumns = 4

    /// A space's background: the base near-black tinted with the space's accent.
    static func spaceBackground(accent: UInt32) -> Color {
        Color(hex: Color.mix(Palette.backgroundBase, accent, amount: backgroundTint))
    }
}

extension Color {
    /// Creates an opaque colour from a 24-bit RGB value such as `0x9B8CFF`.
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    /// Mixes two 24-bit RGB values channel by channel; `amount` 0 gives `base`, 1 gives `other`.
    static func mix(_ base: UInt32, _ other: UInt32, amount: Double) -> UInt32 {
        [16, 8, 0].reduce(UInt32(0)) { result, shift in
            let from = Double((base >> shift) & 0xFF)
            let to = Double((other >> shift) & 0xFF)
            let channel = UInt32((from + (to - from) * amount).rounded())
            return result | (channel << shift)
        }
    }
}
