import SwiftUI
import ZenModel
import ZenState
import ZenWeb

/// An open tab: the page full screen with only the bottom bar (spec §3.4).
/// A sideways swipe on the page goes back or forward in its history.
struct PageScreen: View {
    let state: BrowserState
    let tab: ZenModel.Tab
    let webViews: WebViewStore
    let onDrag: @MainActor (CGFloat) -> Void
    let onRelease: @MainActor (CGFloat, CGFloat) -> Void
    let onShowSpace: @MainActor () -> Void

    @State private var swipeOffset: CGFloat = 0
    private let swipe = GestureMetrics.pageSwipe

    var body: some View {
        let accent = state.data.currentSpace.accentColor
        WebPage(webView: webViews.webView(for: tab), onSwipe: handleSwipe)
            .offset(x: swipeOffset)
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

    /// The page follows the finger towards a page it can go to, then navigates or snaps back on release.
    private func handleSwipe(_ event: PageSwipeEvent) {
        let canGoBack = webViews.canGoBack(tab.id)
        let canGoForward = webViews.canGoForward(tab.id)
        switch event {
        case .changed(let translation):
            swipeOffset = swipe.offset(translation: translation, canGoBack: canGoBack, canGoForward: canGoForward)
        case .ended(let translation, let velocity):
            let outcome = swipe.outcome(
                translation: translation, velocity: velocity, canGoBack: canGoBack, canGoForward: canGoForward)
            switch outcome {
            case .back: webViews.goBack(tab.id)
            case .forward: webViews.goForward(tab.id)
            case .stay: break
            }
            withAnimation(Motion.snapBack) { swipeOffset = 0 }
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
