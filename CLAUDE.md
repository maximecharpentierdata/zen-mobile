# Zen for iPhone

An iOS browser that brings Zen Browser's vertical tabs, Spaces, folders and Essentials to the iPhone. It uses WebKit, copies pieces of Mozilla's firefox-ios (MPL-2.0) where they fit, and is written in SwiftUI. The licence is MPL-2.0.

## Read first
- `docs/product-spec.md`: what the app does. It is the source of truth for behaviour.
- `docs/architecture.md`: modules, toolchain, reuse of Mozilla code.
- `docs/coding-rules.md`: the rules every change must follow. This file adds Claude-specific rules on top of them.
- `docs/design.md` and `docs/roadmap.md`.

## Layout
- `App/`: the iOS app target. It only wires dependencies.
- `Packages/ZenModel`: pure Swift model and tree operations. No UIKit or SwiftUI.
- `Packages/ZenStore`: persistence. Depends only on ZenModel and Foundation.
- `Packages/ZenState`: the live `BrowserState`, user intents, saving, list helpers. No UIKit or SwiftUI.
- `Packages/ZenUI`: SwiftUI screens. Constants live only in `Theme.swift`, `Motion.swift` and `GestureMetrics.swift`.
- `project.yml`: XcodeGen spec. The `.xcodeproj` is generated and never committed.

## Commands
- `swift test --package-path Packages/ZenModel` (and the same for `ZenStore` and `ZenState`): runs on Linux and macOS.
- `swift format lint --strict --recursive App/Sources Packages/*/Sources Packages/*/Tests`: formatting check. Use `swift format --in-place` with the same paths to fix.
- `swiftlint lint --strict`: safety and size limits.
- `xcodegen generate`, then `xcodebuild build -project ZenMobile.xcodeproj -scheme ZenMobile -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO`: macOS only.

Without a Swift toolchain (for example on a Linux sandbox), you can't run these. Rely on CI and say so in the PR; never claim a check passed that you didn't run.

## How Claude works in this repo
1. **Start from the spec.** Find the spec section for the task. If the spec doesn't cover a behaviour, add an open question to the spec and ask. Never invent behaviour, values or facts.
2. **Plan small.** One roadmap item or fix per PR. Branch from up-to-date `main` with a `feat/`, `fix/`, `docs/` or `chore/` name.
3. **Write the tests first** for ZenModel and ZenStore changes, then the code.
4. **Keep the code clean:**
   - One main type per file, and the file is named after it.
   - Size limits are enforced by SwiftLint: files ≤ 300 lines, types ≤ 200 lines, functions ≤ 40 lines, cyclomatic complexity ≤ 8. Split code before you reach them; never raise the limits or add `swiftlint:disable` to get around them.
   - No dead code, no commented-out code, and no `TODO` without a linked issue.
   - No duplication. Extract a shared function or view on the second copy.
   - Every `public` declaration has a `///` doc comment. Comments explain *why*, not *what*.
   - Name things with the spec's vocabulary (`Space`, `Essentials`, `PinnedItem`, `Folder`, `Tab`).
   - In files that import SwiftUI, write `ZenModel.Tab`: SwiftUI has its own `Tab` type.
   - Dependencies only point downward: App may use every package; ZenUI may use ZenState and ZenModel; ZenState may use ZenStore and ZenModel; ZenStore may use ZenModel; ZenModel imports only Foundation.
5. **Keep the docs true.** If a change alters behaviour, update `docs/product-spec.md` in the same PR. If it alters structure, update `docs/architecture.md`. Tick off roadmap items as they land.
6. **Before pushing:** run every check above that the environment allows, re-read the diff, and remove debugging leftovers.
7. **PR description:** what changes, which spec section it implements, how it was checked, and what was not checked (for example "not run on a device").

## Never
- Remove an MPL-2.0 header or the "Copied from" line from a file taken from Mozilla.
- Add a third-party dependency without the owner's agreement.
- Skip, disable or delete a test to make CI pass.
- Commit generated files (`*.xcodeproj`, `.build/`).
- Put a gesture threshold, animation timing, colour or spacing value anywhere other than the files listed above.
