import SwiftUI

/// The root of the app's interface.
public struct RootView: View {
    /// Creates the root view.
    public init() {}

    /// The view's content.
    public var body: some View {
        ZStack {
            Theme.Palette.defaultSpaceBackground.ignoresSafeArea()
            Text("Zen")
                .font(.largeTitle.bold())
                .foregroundStyle(Theme.Palette.primaryText)
        }
    }
}

#Preview {
    RootView()
}
