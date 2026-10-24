# Architecture

Status: living document. Reuse strategy decided on 2026-10-24: our own app, with our own thin web layer that copies Mozilla pieces where useful (§3).

## 1. Platform and toolchain

| Item | Choice | Why |
|---|---|---|
| Language | Swift 6, strict concurrency on | Current Swift; data races are caught at compile time |
| UI | SwiftUI, with UIKit where needed (web view, the bar gesture) | SwiftUI for screens; UIKit for precise gesture and web-view control |
| Minimum iOS | 18.0 *(proposal)* | Gives the recent SwiftUI APIs, including `UIGestureRecognizerRepresentable`. BrowserKit itself only needs iOS 15 |
| Project | XcodeGen (`project.yml`); the `.xcodeproj` is generated and not committed | Avoids merge conflicts in `project.pbxproj` |
| Dependencies | Swift Package Manager only | One tool |
| Web engine | WebKit `WKWebView`, through our own `ZenWeb` layer | Required on iOS outside the EU |

Building and running the app needs **macOS with Xcode**. The pure-Swift packages (`ZenModel`, `ZenStore`, `ZenState`) are written to also build and test on Linux with `swift test`, so they can be tested without a Mac.

## 2. Modules

```
zen-mobile/
├─ App/                    iOS app target: entry point, dependency wiring
├─ Packages/
│  ├─ ZenModel/            Pure Swift. Space, Tab, Folder, Essentials and tree operations
│  │                       (move, pin, unpin, reorder). No UIKit/SwiftUI. Fully unit-tested.
│  ├─ ZenStore/            Persistence of ZenModel (Codable JSON, atomic file writes), migrations.
│  ├─ ZenState/            The live `BrowserState` (@Observable, main actor), user intents, debounced
│  │                       saving, list presentation helpers. No UIKit/SwiftUI, so tested on Linux.
│  ├─ ZenWeb/              Our thin WKWebView layer: tab ↔ web view lifecycle, page icons, snapshots,
│  │                       unloading.
│  └─ ZenUI/               SwiftUI screens and components: space screen, pager, page + bar,
│                          gesture controller, transitions.
├─ docs/
└─ project.yml
```

Dependency direction: `App → ZenUI → ZenWeb`, and `ZenUI → ZenState → ZenStore → ZenModel`. `ZenModel` depends on nothing.

## 3. Reusing Mozilla code

What I checked on GitHub (2026-10-24):
- `mozilla-mobile/firefox-ios` is MPL-2.0. It is a monorepo with the Firefox and Focus apps plus `BrowserKit`.
- `BrowserKit` is a Swift package (`swift-tools-version: 6.2`, iOS 15+) with 23 products, including `WebEngine`, `Common`, `SiteImageView`, `TabDataStore`, `ContentBlockingGenerator`, `ToolbarKit` and `ComponentLibrary`.
- `WebEngine` depends on `Common` and `GCDWebServers`. Mozilla's `SampleBrowser` is "a web browser reference implementation using the WebEngine package".
- `BrowserKit/Package.swift` sits in a subfolder of the repo. As far as I know, SwiftPM can't add a package from a subfolder of a remote repo, so a package could only be taken by copying it.

What it would bring in (checked in `BrowserKit/Package.swift` and `Sources/WebEngine` at commit `783d862`):
- `WebEngine` is about 5,000 lines in 70 Swift files, and its README says it is "under development". 23 of its files import `Common`, mostly for `Logger` and theming. It uses `GCDWebServers` for a local web server that serves internal pages.
- `Common` depends on three third-party packages: `Dip`, `SwiftyBeaver` and `Sentry-Dynamic` (crash reporting).

**Decision (2026-10-24): we write our own thin web layer.** `ZenWeb` is a small `WKWebView` layer sized to what we need (tabs, navigation state, snapshots, unloading). Mozilla's `WebEngine` and `SampleBrowser` are the reference for how to do it. No Mozilla package is vendored as a whole, and no third-party dependency is added.

How we copy pieces:
- When a Mozilla file is worth taking (for example a user script or a URL helper), copy it into the package that needs it. Keep its MPL-2.0 header and add a line under it: `// Copied from mozilla-mobile/firefox-ios <path> at <commit>`.
- Remove what we don't use, and replace `Common` dependencies (logger, theming) with our own small equivalents.
- Our own code is MPL-2.0 as well.
- Zen desktop (Gecko, MPL-2.0) is used as a reference for behaviour and concepts only; no code is reused from it.
- The app icon (`App/Assets.xcassets/AppIcon.appiconset`) is Zen desktop's `configs/branding/release/logo1024.png` at commit `2ad1945`, with its transparent corners filled with the icon's own background colour (`#202020`), since iOS requires an opaque square and rounds the corners itself.

## 4. State and data flow
- One `@Observable` `BrowserState` on the main actor holds the spaces, the current space, the open tab and the gesture state. Views read it; changes go through methods on it, which call pure functions in `ZenModel`.
- `ZenStore` saves after changes (debounced, about 0.5 s) and on going to the background.
- Web views live in `ZenWeb`'s `WebViewPool`, keyed by tab id. They are created when needed, can be unloaded under memory pressure, and are restored from saved navigation state.
- Each page also has an `@Observable` `PageNavigation` in `ZenWeb`: it follows the web view's back/forward state through key-value observation and carries the page menu's actions (back, forward, reload, find, desktop site). The page menu reads it directly, since this state belongs to the web view, not to the model.

## 5. Key UI mechanics
- **Space pager (2A):** a horizontal paging scroll view over the spaces, with the background colour blended from the scroll offset. Vertical lists are inside each page and lock their direction.
- **Open/close transition (3A):** it animates from the tab row's frame to full screen using the tab's snapshot image, then swaps in the live web view at the end. Closing does the reverse into the row's current frame.
- **Bar gesture (4A):** a UIKit pan recognizer on the bar, bridged into SwiftUI. It produces a single `progress` value (0 to stop 2). The page scale, the stop markers and the haptics are all driven from that one value, so the animation is interruptible and stays in sync with the finger. Release logic uses distance plus velocity (spec §3.5).
- **Page swipe (§3.4):** a UIKit pan recognizer that `ZenWeb`'s `WebPage` adds once to each web view. It reports the sideways translation to SwiftUI; `ZenState`'s `PageSwipe` decides between staying, back and forward, with thresholds from `GestureMetrics`.
- **Minimizing page bar (§3.4):** `WebPage`'s coordinator, a `PageScrollObserver`, listens to the web view's scroll pan recognizer (WebKit keeps the scroll view's delegate) and reports the finger's vertical travel. `ZenState`'s `BarScroll` decides when the bar minimizes or expands. It follows the finger, not the scroll position, because the scroll position also moves when the page's insets change with the bar. The observer also follows `contentOffset` through key-value observation, to report when the page reaches or leaves its top.
- **Edge-to-edge page (§3.4):** `RootView` lays the open page over the whole screen, ignoring the safe area, and passes it the safe area insets. `PageScreen` places the bar and the status bar backdrop from them, and gives the web view matching content insets (with `contentInsetAdjustmentBehavior = .never`) so the page's top starts below the status bar and its end scrolls clear of the bar.
- **Pull to refresh (§3.4):** the system `UIRefreshControl` on each web view's scroll view, added by `WebViewStore` when it creates the page. It reloads the page and stops its spinner when the web view's `isLoading` turns false.

## 6. Testing
- `ZenModel`, `ZenStore` and `ZenState`: unit tests with `swift test`, which run on Linux and macOS.
- `ZenUI`: snapshot or preview tests for the screens; UI tests for the main flows (open tab, back to space, new tab, change space) on macOS CI.
- CI: GitHub Actions. Linux runs `swift test` on the pure packages; macOS runs the full app build and UI tests. The macOS runners and their minutes need checking on this repo.
