import SwiftUI
import ZenState

/// The root of the app's interface.
public struct RootView: View {
    private let state: BrowserState

    /// Creates the root view for this state.
    public init(state: BrowserState) {
        self.state = state
    }

    /// The view's content.
    public var body: some View {
        SpaceScreen(state: state)
    }
}

#Preview {
    RootView(state: BrowserState(data: DemoData.browserData(now: .now)))
}
