import SwiftUI

/// Colours, spacing and radii from `docs/design.md`. Views take visual constants from here only.
enum Theme {
    /// Colours shared by every space.
    enum Palette {
        static var primaryText: Color { Color(hex: 0xF3F2F8) }
        static var secondaryText: Color { Color(hex: 0xABA8BE) }
        /// Background of the first-launch "Personal" space until spaces carry their own colours.
        static var defaultSpaceBackground: Color { Color(hex: 0x1D1A2B) }
    }

    /// Spacing in points.
    enum Spacing {
        static let screenMargin: CGFloat = 16
        static let section: CGFloat = 18
    }

    /// Corner radii in points.
    enum Radius {
        static let tabRow: CGFloat = 12
        static let essentialTile: CGFloat = 16
    }

    /// Fixed sizes in points.
    enum Size {
        static let tabRowHeight: CGFloat = 44
        static let essentialTileHeight: CGFloat = 60
        static let bottomBarHeight: CGFloat = 50
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
}
