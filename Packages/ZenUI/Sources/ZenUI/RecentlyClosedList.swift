import SwiftUI
import ZenModel
import ZenState

/// Tabs closed by hand or by the automatic clean-up, most recent first. Tapping one reopens it at the top of
/// the current space (spec §3.2).
struct RecentlyClosedList: View {
    let state: BrowserState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(state.data.recentlyClosed) { tab in
                Button {
                    state.restoreClosedTab(tab.id)
                } label: {
                    TabRow(tab: tab, accent: state.data.currentSpace.accentColor)
                }
                .accessibilityHint(Text("Reopens the tab"))
            }
            .overlay {
                if state.data.recentlyClosed.isEmpty {
                    ContentUnavailableView("No recently closed tabs", systemImage: "clock")
                }
            }
            .navigationTitle(Text("Recently closed"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
