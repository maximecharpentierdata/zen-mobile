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
        let webViews = WebViewStore(
            onPageChange: { id, url, title in state.pageDidChange(id, url: url, title: title) },
            onFaviconChange: { id, url in state.faviconDidChange(id, url: url) }
        )
        _webViews = State(initialValue: webViews)
    }

    var body: some Scene {
        WindowGroup {
            // Only the dark appearance is designed (design.md), so system controls, menus and the keyboard
            // follow it too.
            RootView(state: state, webViews: webViews)
                .preferredColorScheme(.dark)
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
            // Sample content without touching saved data, for demos.
            let environment = ProcessInfo.processInfo.environment
            if environment["ZEN_DEMO_DATA"] == "1" {
                let state = BrowserState(data: DemoData.browserData(now: .now))
                DemoData.showScreen(environment["ZEN_DEMO_SCREEN"], in: state)
                return state
            }
        #endif
        return BrowserState.load(
            from: FileStore(fileURL: URL.applicationSupportDirectory.appending(path: "browser.json"))
        )
    }
}
