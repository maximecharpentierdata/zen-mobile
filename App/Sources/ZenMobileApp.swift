import SwiftUI
import ZenState
import ZenStore
import ZenUI

@main
struct ZenMobileApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var state = Self.makeState()

    var body: some Scene {
        WindowGroup {
            RootView(state: state)
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
