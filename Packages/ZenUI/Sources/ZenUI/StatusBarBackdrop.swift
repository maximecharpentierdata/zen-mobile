import SwiftUI

/// The blur behind the status bar, so an open page can run under it as in Safari (spec §3.4).
///
/// It has no height of its own: it sits at the top of the safe area and only its background reaches up into it.
struct StatusBarBackdrop: View {
    var body: some View {
        Color.clear
            .frame(height: 0)
            .background(Theme.barMaterial, ignoresSafeAreaEdges: .top)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
