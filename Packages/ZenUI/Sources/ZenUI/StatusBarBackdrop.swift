import SwiftUI

/// The blur behind the status bar once the page scrolls down, so the page runs under it as in Safari (spec §3.4).
struct StatusBarBackdrop: View {
    /// The status bar's height: the top of the screen's safe area.
    let height: CGFloat

    var body: some View {
        Rectangle()
            .fill(Theme.barMaterial)
            .frame(height: height)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
