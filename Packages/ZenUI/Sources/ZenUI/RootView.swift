import SwiftUI
import ZenState
import ZenWeb

/// The root of the app's interface: the space screen, or the open page on top of it.
public struct RootView: View {
    private let state: BrowserState
    private let webViews: WebViewStore

    /// Creates the root view for this state. `webViews` keeps the pages loaded between visits.
    public init(state: BrowserState, webViews: WebViewStore) {
        self.state = state
        self.webViews = webViews
    }

    /// The view's content.
    public var body: some View {
        if let tab = state.openTab {
            PageScreen(state: state, tab: tab, webViews: webViews)
        } else {
            SpaceScreen(state: state)
        }
    }
}

#Preview {
    let state = BrowserState(data: DemoData.browserData(now: .now))
    let webViews = WebViewStore { id, url, title in
        state.pageDidChange(id, url: url, title: title)
    }
    RootView(state: state, webViews: webViews)
}
