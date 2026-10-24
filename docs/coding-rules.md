# Coding rules

These rules apply to every contributor, human or AI.

## General
- Read [product-spec.md](product-spec.md) and [architecture.md](architecture.md) before changing behaviour. If the code and the spec disagree, fix one of them in the same PR, never silently.
- Keep changes small: one feature or fix per PR.
- Don't invent behaviour that isn't in the spec. If something is missing, add an open question to the spec, or ask.

## Swift
- Swift 6 language mode, with strict concurrency set to `complete`. No `@unchecked Sendable` and no `nonisolated(unsafe)` without a comment explaining why it is safe.
- UI state and views are `@MainActor`.
- Don't use force unwraps (`!`) or `try!` outside tests. `fatalError` is only for impossible states, with a message.
- Prefer value types (`struct`, `enum`). `ZenModel` contains only value types and pure functions.
- Use `async`/`await`, not completion handlers, in new code.
- Naming follows the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/). Use spec vocabulary in code: `Space`, `Essentials`, `PinnedItem`, `Folder`, `Tab`.
- Access control: everything is `internal` by default. Only a package's API is `public`.
- Formatting: `swift-format`, using the repo config. Linting: SwiftLint, using the repo config. Both run in CI and must pass.

## SwiftUI and UIKit
- Views stay small. Logic lives in `BrowserState` or `ZenModel`, not in view bodies.
- Every interactive element has an accessibility label. Every gesture has a non-gesture alternative (spec §5).
- Respect Reduce Motion and Dynamic Type.
- Animations use springs, and their constants live in one file (`ZenUI/Motion.swift`). Gesture thresholds live in one file (`ZenUI/GestureMetrics.swift`), so the *(tune)* values in the spec are easy to adjust.
- Use no magic numbers for layout: spacing, radii and colours come from `ZenUI/Theme.swift`.

## Dependencies
- No new third-party dependency without the owner's agreement in the PR.
- Vendored Mozilla code is only updated with `scripts/vendor-browserkit.sh`, never edited by hand (architecture §3).
- Files copied from MPL-2.0 sources keep their licence header.

## Tests
- Every change to `ZenModel` or `ZenStore` comes with unit tests.
- Every bug fix comes with a test that fails without the fix, when the bug can be tested.
- Never skip, disable or delete a test to make CI pass.

## Git and PRs
- Branches are named `feat/…`, `fix/…`, `docs/…` or `chore/…`.
- Commit messages follow Conventional Commits (`feat: add space pager`).
- A PR explains what it changes and why, and links the spec section it implements. UI PRs include a screenshot or screen recording.
- `main` is always buildable. PRs are merged after review and green CI.

## Text and localisation
- Every user-facing string goes in String Catalogs (`Localizable.xcstrings`), in English for v1.
