import SwiftUI
import ZenModel
import ZenState
import ZenWeb

/// An open tab: the page full screen with only the bottom bar (spec §3.4).
struct PageScreen: View {
    let state: BrowserState
    let tab: ZenModel.Tab
    let webViews: WebViewStore
    let onDrag: @MainActor (CGFloat) -> Void
    let onRelease: @MainActor (CGFloat, CGFloat) -> Void
    let onShowSpace: @MainActor () -> Void

    var body: some View {
        let accent = state.data.currentSpace.accentColor
        WebPage(webView: webViews.webView(for: tab))
            .id(tab.id)
            .ignoresSafeArea(.container, edges: .bottom)
            .safeAreaInset(edge: .bottom) {
                bottomControl
                    .padding(.horizontal, Theme.Spacing.screenMargin)
                    .padding(.bottom, Theme.Spacing.grid)
            }
            .background(Theme.spaceBackground(accent: accent).ignoresSafeArea())
            .onChange(of: tab.url) { _, url in
                if let url { webViews.load(url, in: tab) }
            }
    }

    @ViewBuilder
    private var bottomControl: some View {
        if state.isEditingAddress {
            AddressEditor(
                initialText: tab.url?.absoluteString ?? "",
                onSubmit: { state.submitAddress($0) },
                onCancel: { state.cancelAddressEditing() }
            )
        } else {
            PageBar(
                tab: tab,
                onTap: { state.editAddress() },
                onShowSpace: onShowSpace,
                onNewTab: { state.startNewTab() },
                onDrag: onDrag,
                onRelease: onRelease
            )
        }
    }
}
