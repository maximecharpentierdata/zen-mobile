import SwiftUI
import UIKit
import ZenModel
import ZenState
import ZenWeb

/// The root of the app's interface: the space screen, with the open page on top of it.
///
/// It owns the page's presentation: growing from its row when opened (design 3A), following the bar gesture,
/// and shrinking back into its row (spec §3.4, §3.5; design 4A).
public struct RootView: View {
    private let state: BrowserState
    private let webViews: WebViewStore
    private let gesture = GestureMetrics.barGesture

    @State private var rowFrames = RowFrames()
    @State private var screenFrame = CGRect.zero
    /// 0 when the page is full screen, 1 when it sits on its row. Animated when opening and closing.
    @State private var collapse: CGFloat = 0
    /// How far the page bar is dragged up, in points.
    @State private var dragDistance: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates the root view for this state. `webViews` keeps the pages loaded between visits.
    public init(state: BrowserState, webViews: WebViewStore) {
        self.state = state
        self.webViews = webViews
    }

    /// The view's content.
    public var body: some View {
        ZStack {
            SpaceScreen(state: state, onOpen: open, onNewTab: startNewTab)
                .allowsHitTesting(state.openTab == nil)
                .accessibilityHidden(state.openTab != nil)
            if let tab = state.openTab {
                page(for: tab)
                    .id(tab.id)
                    .transition(.opacity)
            }
            if dragDistance > 0 {
                StopMarkers(stage: stage, accent: state.data.currentSpace.accentColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .padding(.trailing, Theme.Spacing.screenMargin)
            }
        }
        .environment(\.rowFrames, rowFrames)
        .onChange(of: state.data.allTabIDs) { _, openTabs in
            // A closed tab's page is freed at once (spec §4).
            webViews.unloadAll(except: openTabs)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            // Low memory: keep only the page on screen. Others reload from their URL when opened (spec §4).
            webViews.unloadAll(except: Set([state.openTabID].compactMap { $0 }))
        }
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { frame in
            screenFrame = frame
        }
        .sensoryFeedback(.impact(weight: .light), trigger: stage) { _, newStage in newStage != .stay }
    }

    private var stage: BarGesture.Outcome {
        gesture.stage(upwardDistance: dragDistance)
    }

    /// How far the page is towards its row, from the animation or the finger, whichever is further.
    private var progress: CGFloat {
        max(collapse, CGFloat(gesture.shrink(upwardDistance: dragDistance)) * GestureMetrics.barMaxDragCollapse)
    }

    private func page(for tab: ZenModel.Tab) -> some View {
        let row = rowFrames.frame(for: tab.id) ?? fallbackRow
        let transform = PageTransform(
            progress: progress,
            page: screenFrame,
            row: row,
            rowCornerRadius: Theme.Radius.tabRow
        )
        return PageScreen(
            state: state,
            tab: tab,
            webViews: webViews,
            onDrag: { dragDistance = max($0, 0) },
            onRelease: release,
            onShowSpace: closePage
        )
        .mask {
            RoundedRectangle(cornerRadius: CGFloat(transform.cornerRadius))
                .frame(height: CGFloat(transform.maskHeight))
        }
        .scaleEffect(CGFloat(transform.scale))
        .offset(x: transform.offsetX, y: transform.offsetY)
        .opacity(transform.opacity)
        .onAppear(perform: animateOpen)
    }

    /// Where a page without a visible row (a brand-new tab) grows from and shrinks to: the new-tab button.
    private var fallbackRow: CGRect {
        let size = Theme.Size.bottomBarHeight
        return CGRect(x: screenFrame.maxX - size, y: screenFrame.maxY - size, width: size, height: size)
    }

    private func open(_ id: ZenModel.Tab.ID) {
        present { state.open(id) }
    }

    private func startNewTab() {
        present { state.startNewTab() }
    }

    /// Shows a page: it grows from its row, or crossfades in with Reduce Motion (spec §3.4, §5).
    private func present(_ change: () -> Void) {
        guard !reduceMotion else {
            withAnimation(Motion.crossfade, change)
            return
        }
        collapse = 1
        change()
    }

    private func animateOpen() {
        withAnimation(Motion.openTab) { collapse = 0 }
    }

    private func release(distance: CGFloat, velocity: CGFloat) {
        switch gesture.outcome(upwardDistance: distance, upwardVelocity: velocity) {
        case .stay:
            withAnimation(Motion.snapBack) { dragDistance = 0 }
        case .showSpace:
            closePage()
        case .newTab:
            dragDistance = 0
            startNewTab()
        }
    }

    /// Shrinks the page into its row, then shows the space screen (spec §3.5, stop 1).
    private func closePage() {
        guard !reduceMotion else {
            dragDistance = 0
            withAnimation(Motion.crossfade) { state.showSpace() }
            return
        }
        collapse = progress
        dragDistance = 0
        withAnimation(Motion.openTab, completionCriteria: .logicallyComplete) {
            collapse = 1
        } completion: {
            state.showSpace()
            collapse = 0
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
