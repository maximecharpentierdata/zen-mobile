import SwiftUI
import ZenState
import ZenStore
import ZenUI
import ZenWeb

@main
struct ZenMobileApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var state: BrowserState
    @State private var webViews: WebViewStore

    init() {
        let state = Self.makeState()
        _state = State(initialValue: state)
        _webViews = State(initialValue: WebViewStore { id, url, title in
            state.pageDidChange(id, url: url, title: title)
        })
    }

    var body: some Scene {
        WindowGroup {
            RootView(state: state, webViews: webViews)
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                state.closeStaleTabs()
            case .background:
                state.saveNow()
            default:
                break
            }
        }
    }

    @MainActor
    private static func makeState() -> BrowserState {
        #if DEBUG
            // Sample content without touching saved data, for CI screenshots and demos.
            if ProcessInfo.processInfo.environment["ZEN_DEMO_DATA"] == "1" {
                return BrowserState(data: DemoData.browserData(now: .now))
            }
        #endif
        return BrowserState.load(
            from: FileStore(fileURL: URL.applicationSupportDirectory.appending(path: "browser.json"))
        )
    }
}
