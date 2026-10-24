import SwiftUI

/// Animation constants. Every timing marked *(tune)* in `docs/product-spec.md` lives here and only here.
enum Motion {
    /// Tab row growing into the full-screen page, and back (spec §3.4).
    static var openTab: Animation { .spring(duration: 0.35, bounce: 0.1) }
    /// The pager moving to a space chosen without a swipe, for example with VoiceOver (spec §3.3, §5).
    static var changeSpace: Animation { .spring(duration: 0.35, bounce: 0) }
    /// Opening and closing a page when Reduce Motion is on: a crossfade instead of the zoom (spec §5).
    static var crossfade: Animation { .easeInOut(duration: 0.25) }
    /// The page bar minimizing as the page scrolls down, and expanding again (spec §3.4).
    static var barResize: Animation { .spring(duration: 0.25, bounce: 0) }
    /// A gesture released before its first threshold returns to rest.
    static var snapBack: Animation { .spring(duration: 0.3, bounce: 0) }
}
