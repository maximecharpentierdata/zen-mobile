import SwiftUI

/// Animation constants. Every timing marked *(tune)* in `docs/product-spec.md` lives here and only here.
enum Motion {
    /// Tab row growing into the full-screen page, and back (spec §3.4).
    static var openTab: Animation { .spring(duration: 0.35, bounce: 0.1) }
    /// The pager moving to a space chosen without a swipe, for example with VoiceOver (spec §3.3, §5).
    static var changeSpace: Animation { .spring(duration: 0.35, bounce: 0) }
    /// A gesture released before its first threshold returns to rest.
    static var snapBack: Animation { .spring(duration: 0.3, bounce: 0) }
}
