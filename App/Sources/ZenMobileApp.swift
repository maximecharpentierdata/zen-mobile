import SwiftUI
import ZenState
import ZenStore
import ZenUI

@main
struct ZenMobileApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var state = BrowserState.load(
        from: FileStore(fileURL: URL.applicationSupportDirectory.appending(path: "browser.json"))
    )

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
}
