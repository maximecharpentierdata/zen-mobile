import SwiftUI
import ZenModel
import ZenState
import ZenWeb

/// An open tab: the page full screen with only the bottom bar and its page menu (spec §3.4).
/// A sideways swipe on the page goes back or forward in its history.
///
/// As in Safari, the page runs under the blurred status bar. The expanded bar sits below the page so it hides
/// nothing; once the page scrolls down the bar minimizes and the page runs under it to the bottom edge.
struct PageScreen: View {
    let state: BrowserState
    let tab: ZenModel.Tab
    let webViews: WebViewStore
    let onDrag: @MainActor (CGFloat) -> Void
    let onRelease: @MainActor (CGFloat, CGFloat) -> Void
    let onShowSpace: @MainActor () -> Void

    @State private var swipeOffset: CGFloat = 0
    @State private var barScroll = GestureMetrics.barScroll
    private let swipe = GestureMetrics.pageSwipe

    var body: some View {
        let accent = state.data.currentSpace.accentColor
        WebPage(webView: webViews.webView(for: tab), onSwipe: handleSwipe, onScroll: handleScroll)
            .offset(x: swipeOffset)
            .id(tab.id)
            .overlay { if state.isEditingAddress { dismissArea } }
            .ignoresSafeArea(.container, edges: isBarMinimized ? .vertical : .top)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomControl
                    .padding(.horizontal, Theme.Spacing.screenMargin)
                    .padding(.vertical, isBarMinimized ? 0 : Theme.Spacing.grid)
            }
            .overlay(alignment: .top) { StatusBarBackdrop() }
            .background(Theme.spaceBackground(accent: accent).ignoresSafeArea())
            .onChange(of: tab.url) { _, url in
                if let url { webViews.load(url, in: tab) }
                expandBar()
            }
    }

    /// Address editing always shows the full bar.
    private var isBarMinimized: Bool {
        barScroll.isMinimized && !state.isEditingAddress
    }

    /// The bar minimizes as the finger scrolls the page down and expands as it scrolls back up.
    private func handleScroll(_ event: PageScrollEvent) {
        var next = barScroll
        switch event {
        case .began:
            next.dragBegan()
        case .moved(let translation, let isAtTop, let canScroll):
            next.dragMoved(translation: translation, isAtTop: isAtTop, canScroll: canScroll)
        }
        guard next.isMinimized != barScroll.isMinimized else {
            barScroll = next
            return
        }
        withAnimation(Motion.barResize) { barScroll = next }
    }

    private func expandBar() {
        withAnimation(Motion.barResize) { barScroll.expand() }
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
                candidates: state.data.addressCandidates,
                accent: state.data.currentSpace.accentColor,
                onSubmit: { state.submitAddress($0) }
            )
        } else {
            HStack(spacing: Theme.Spacing.grid) {
                PageBar(
                    tab: tab,
                    isMinimized: isBarMinimized,
                    onTap: { isBarMinimized ? expandBar() : state.editAddress() },
                    onDoubleTap: isBarMinimized ? nil : resetToPinnedURL,
                    onShowSpace: onShowSpace,
                    onNewTab: { state.startNewTab() },
                    onDrag: onDrag,
                    onRelease: onRelease
                )
                if !isBarMinimized {
                    PageMenu(url: tab.url, navigation: webViews.navigation(for: tab))
                }
            }
        }
    }

    /// While the address field is open, a tap on the page closes it without loading anything (spec §3.4).
    private var dismissArea: some View {
        Color.clear
            .contentShape(.rect)
            .onTapGesture { state.cancelAddressEditing() }
            .accessibilityHidden(true)
    }

    /// Only pinned tabs and Essentials go back to a pinned URL on a double tap (spec §3.4).
    private var resetToPinnedURL: (@MainActor () -> Void)? {
        guard tab.pinnedURL != nil else { return nil }
        let state = state
        let id = tab.id
        return { state.resetToPinnedURL(id) }
    }
}
