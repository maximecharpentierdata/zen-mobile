import UIKit

/// Follows the finger on a web view's scroll view, for minimizing the page bar, and whether the page is at its top,
/// for the status bar backdrop (spec §3.4).
///
/// It listens to the scroll view's own pan recognizer rather than replacing the scroll view's delegate, which
/// WebKit uses.
@MainActor
public final class PageScrollObserver: NSObject {
    var onScroll: @MainActor (PageScrollEvent) -> Void
    private weak var scrollView: UIScrollView?
    private var offsetObservation: NSKeyValueObservation?
    private var wasAtTop: Bool?

    init(onScroll: @escaping @MainActor (PageScrollEvent) -> Void) {
        self.onScroll = onScroll
    }

    /// Starts following `scrollView`, and stops following the previous one.
    func attach(to scrollView: UIScrollView) {
        guard self.scrollView !== scrollView else { return }
        detach()
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(report(_:)))
        self.scrollView = scrollView
        offsetObservation = scrollView.observe(\.contentOffset, options: [.initial]) { [weak self] _, _ in
            MainActor.assumeIsolated { self?.reportTop() }
        }
    }

    /// Stops following the scroll view. The web view outlives the SwiftUI view that shows it.
    func detach() {
        scrollView?.panGestureRecognizer.removeTarget(self, action: #selector(report(_:)))
        scrollView = nil
        offsetObservation = nil
        wasAtTop = nil
    }

    /// Reports only changes, since the offset moves on every frame of a scroll. The offset can also change while
    /// SwiftUI updates the view, so the report waits for that update to finish.
    private func reportTop() {
        guard let scrollView else { return }
        let isAtTop = scrollView.isAtTop
        guard isAtTop != wasAtTop else { return }
        wasAtTop = isAtTop
        Task { @MainActor [weak self] in self?.onScroll(.topChanged(isAtTop: isAtTop)) }
    }

    /// Measured in the web view, because the scroll view's own coordinates move with the page.
    @objc private func report(_ pan: UIPanGestureRecognizer) {
        guard let scrollView else { return }
        switch pan.state {
        case .began:
            onScroll(.began)
        case .changed:
            let event = PageScrollEvent.moved(
                translation: pan.translation(in: scrollView.superview).y,
                isAtTop: scrollView.isAtTop,
                canScroll: scrollView.canScrollVertically
            )
            onScroll(event)
        default:
            break
        }
    }
}

extension UIScrollView {
    /// Whether the page shows its top, or is pulled down past it.
    fileprivate var isAtTop: Bool {
        contentOffset.y <= -adjustedContentInset.top
    }

    /// Whether the page is taller than the space it is shown in.
    fileprivate var canScrollVertically: Bool {
        contentSize.height + adjustedContentInset.top + adjustedContentInset.bottom > bounds.height
    }
}
