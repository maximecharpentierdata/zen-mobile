# Zen for iPhone

An iOS browser that brings Zen Browser's vertical tabs, Spaces, folders and Essentials to the iPhone. It uses WebKit, reuses selected Mozilla BrowserKit modules (MPL-2.0), and is written in SwiftUI.

Before working, read:
- `docs/product-spec.md`: what the app does. It is the source of truth for behaviour.
- `docs/architecture.md`: modules, toolchain, reuse of Mozilla code.
- `docs/coding-rules.md`: the rules every change must follow.
- `docs/design.md` and `docs/roadmap.md`.

Key points:
- Building the app needs macOS and Xcode. On Linux, only `swift test` in `Packages/ZenModel` and `Packages/ZenStore` works.
- Never edit `Vendor/BrowserKit/` by hand; use `scripts/vendor-browserkit.sh`.
- Gesture thresholds and animation constants live only in `ZenUI/GestureMetrics.swift` and `ZenUI/Motion.swift`.
- Don't invent behaviour: if the spec doesn't cover something, add an open question to it.
