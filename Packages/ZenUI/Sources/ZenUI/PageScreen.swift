import SwiftUI
import UIKit
import ZenModel
import ZenState
import ZenWeb

/// An open tab: the page full screen with only the bottom bar and its page menu (spec §3.4).
/// A sideways swipe on the page goes back or forward in its history.
///
/// As in Safari, the page fills the screen from edge to edge and the bar floats over it. The page's insets keep its
/// top below the status bar and let its end scroll clear of the bar. Once the page scrolls down, it runs under a
/// blurred status bar and the bar minimizes.
struct PageScreen: View {
    let state: BrowserState
    let tab: ZenModel.Tab
    let webViews: WebViewStore
    /// The status bar and Home indicator areas. The page ignores the safe area, so it places its controls itself.
    let safeArea: EdgeInsets
    let onDrag: @MainActor (CGFloat) -> Void
    let onRelease: @MainActor (CGFloat, CGFloat) -> Void
    let onShowSpace: @MainActor () -> Void

    @State private var swipeOffset: CGFloat = 0
    @State private var barScroll = GestureMetrics.barScroll
    /// At the top, the status bar shows the page's own colour; the blur only comes once the page scrolls down.
    @State private var isAtTop = true
    private let swipe = GestureMetrics.pageSwipe

    var body: some View {
        let accent = state.data.currentSpace.accentColor
        WebPage(
            webView: webViews.webView(for: tab),
            contentInsets: pageInsets,
            onSwipe: handleSwipe,
            onScroll: handleScroll
        )
        .offset(x: swipeOffset)
        .id(tab.id)
        .overlay { if state.isEditingAddress { dismissArea } }
        .overlay(alignment: .top) {
            StatusBarBackdrop(height: safeArea.top)
                .opacity(isAtTop ? 0 : 1)
        }
        .overlay(alignment: .bottom) {
            bottomControl
                .padding(.horizontal, Theme.Spacing.screenMargin)
                .padding(.bottom, barBottomPadding)
        }
        .background(Theme.spaceBackground(accent: accent))
        .onChange(of: tab.url) { _, url in
            if let url { webViews.load(url, in: tab) }
            expandBar()
        }
    }

    /// The keyboard already lifts the address field above the Home indicator.
    private var barBottomPadding: CGFloat {
        if state.isEditingAddress { return Theme.Spacing.grid }
        return safeArea.bottom + (isBarMinimized ? 0 : Theme.Spacing.grid)
    }

    /// The page's top starts below the status bar, and its end scrolls a gap above the bar.
    private var pageInsets: UIEdgeInsets {
        let bar = isBarMinimized ? Theme.Size.minimizedPageBarHeight : Theme.Size.pageBarHeight
        return UIEdgeInsets(top: safeArea.top, left: 0, bottom: bar + Theme.Spacing.grid + barBottomPadding, right: 0)
    }

    /// Address editing always shows the full bar.
    private var isBarMinimized: Bool {
        barScroll.isMinimized && !state.isEditingAddress
    }

    /// The bar minimizes as the finger scrolls the page down and expands as it scrolls back up or reaches the top.
    private func handleScroll(_ event: PageScrollEvent) {
        var next = barScroll
        switch event {
        case .began:
            next.dragBegan()
        case .moved(let translation, let isAtTop, let canScroll):
            next.dragMoved(translation: translation, isAtTop: isAtTop, canScroll: canScroll)
        case .topChanged(let atTop):
            if atTop { next.expand() }
            withAnimation(Motion.barResize) { isAtTop = atTop }
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
