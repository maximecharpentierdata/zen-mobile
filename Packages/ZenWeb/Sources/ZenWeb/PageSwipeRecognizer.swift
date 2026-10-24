import UIKit
import WebKit

/// A sideways pan anywhere on a web view, for going back and forward (spec §3.4).
///
/// It only starts when the movement is mostly sideways and the page itself can't scroll further that way,
/// so pages wider than the screen keep scrolling. WebKit's own edge swipe stays on beside it.
final class PageSwipeRecognizer: UIPanGestureRecognizer, UIGestureRecognizerDelegate {
    var onSwipe: @MainActor (PageSwipeEvent) -> Void

    init(onSwipe: @escaping @MainActor (PageSwipeEvent) -> Void) {
        self.onSwipe = onSwipe
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(report))
        delegate = self
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let webView = view as? WKWebView else { return false }
        let speed = velocity(in: webView)
        guard abs(speed.x) > abs(speed.y) else { return false }
        return !webView.scrollView.canScrollSideways(fingerMovingRight: speed.x > 0)
    }

    /// Vertical scrolling keeps working while the finger drifts during a sideways swipe.
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        other === (view as? WKWebView)?.scrollView.panGestureRecognizer
    }

    /// Measured in the window, because the page moves with the finger.
    @objc private func report() {
        let space = view?.window
        switch state {
        case .began, .changed:
            onSwipe(.changed(translation: translation(in: space).x))
        case .ended:
            onSwipe(.ended(translation: translation(in: space).x, velocity: velocity(in: space).x))
        case .cancelled, .failed:
            onSwipe(.ended(translation: 0, velocity: 0))
        default:
            break
        }
    }
}

extension UIScrollView {
    /// Whether the content can still scroll when the finger moves sideways in this direction.
    fileprivate func canScrollSideways(fingerMovingRight: Bool) -> Bool {
        let minX = -adjustedContentInset.left
        let maxX = contentSize.width + adjustedContentInset.right - bounds.width
        return fingerMovingRight ? contentOffset.x > minX : contentOffset.x < maxX
    }
}
