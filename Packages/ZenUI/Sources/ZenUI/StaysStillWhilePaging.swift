import SwiftUI

extension View {
    /// Keeps a view that every space page shows in the same place while the pager slides, so it looks like one
    /// view that doesn't belong to any space (spec §3.3).
    ///
    /// Each page draws its own copy, moved back by however far its page has slid. Only the copy of the page
    /// nearest the middle shows, so the copies never stack. `fadesTowardsEnd` is for the last space: the page
    /// after it is not a space, so its copy fades out as that page comes in instead of vanishing halfway.
    func staysStillWhilePaging(fadesTowardsEnd: Bool) -> some View {
        visualEffect { content, proxy in
            let slide = proxy.frame(in: .scrollView).minX
            let width = proxy.bounds(of: .scrollView)?.width ?? 0
            return
                content
                .offset(x: -slide)
                .opacity(StaysStillWhilePaging.opacity(slide: slide, width: width, fadesTowardsEnd: fadesTowardsEnd))
        }
    }
}

/// The opacity rule of `staysStillWhilePaging(fadesTowardsEnd:)`.
private enum StaysStillWhilePaging {
    static func opacity(slide: CGFloat, width: CGFloat, fadesTowardsEnd: Bool) -> Double {
        guard width > 0 else { return 1 }
        if fadesTowardsEnd, slide < 0 { return Double(max(0, 1 + slide / width)) }
        return abs(slide) < width / 2 ? 1 : 0
    }
}
