# Architecture

Status: draft for review. Reuse strategy decided on 2026-10-24: our own app plus selected BrowserKit modules, vendored (§3).

## 1. Platform and toolchain

| Item | Choice | Why |
|---|---|---|
| Language | Swift 6, strict concurrency on | Current Swift; data races are caught at compile time |
| UI | SwiftUI, with UIKit where needed (web view, the bar gesture) | SwiftUI for screens; UIKit for precise gesture and web-view control |
| Minimum iOS | 18.0 *(proposal)* | Gives the recent SwiftUI APIs, including `UIGestureRecognizerRepresentable`. BrowserKit itself only needs iOS 15 |
| Project | XcodeGen (`project.yml`); the `.xcodeproj` is generated and not committed | Avoids merge conflicts in `project.pbxproj` |
| Dependencies | Swift Package Manager only | One tool |
| Web engine | WebKit `WKWebView`, through Mozilla's `WebEngine` module | Required on iOS outside the EU |

Building and running the app needs **macOS with Xcode**. The pure-Swift packages (`ZenModel`, `ZenStore`) are written to also build and test on Linux with `swift test`, so they can be tested without a Mac.

## 2. Modules

```
zen-mobile/
├─ App/                    iOS app target: entry point, dependency wiring
├─ Packages/
│  ├─ ZenModel/            Pure Swift. Space, Tab, Folder, Essentials and tree operations
│  │                       (move, pin, unpin, reorder). No UIKit/SwiftUI. Fully unit-tested.
│  ├─ ZenStore/            Persistence of ZenModel (Codable JSON, atomic file writes), migrations.
│  ├─ ZenWeb/              Tab ↔ web view lifecycle, snapshots, unloading, over WebEngine.
│  └─ ZenUI/               SwiftUI screens and components: space screen, pager, page + bar,
│                          gesture controller, transitions.
├─ Vendor/BrowserKit/      Selected Mozilla BrowserKit modules (MPL-2.0), pinned to a commit.
├─ docs/
└─ project.yml
```

Dependency direction: `App → ZenUI → ZenWeb → (Vendor) WebEngine`, and `ZenUI → ZenStore → ZenModel`. `ZenModel` depends on nothing.

## 3. Reusing Mozilla code

What I checked on GitHub (2026-10-24):
- `mozilla-mobile/firefox-ios` is MPL-2.0. It is a monorepo with the Firefox and Focus apps plus `BrowserKit`.
- `BrowserKit` is a Swift package (`swift-tools-version: 6.2`, iOS 15+) with 23 products, including `WebEngine`, `Common`, `SiteImageView`, `TabDataStore`, `ContentBlockingGenerator`, `ToolbarKit` and `ComponentLibrary`.
- `WebEngine` depends on `Common` and `GCDWebServers`. Mozilla's `SampleBrowser` is "a web browser reference implementation using the WebEngine package".
- `BrowserKit/Package.swift` sits in a subfolder of the repo. As far as I know, SwiftPM can't add a package from a subfolder of a remote repo, so we vendor it.

Plan:
- `scripts/vendor-browserkit.sh <commit>` copies only the needed targets (`WebEngine`, `Common`, then `SiteImageView` when favicons come in) into `Vendor/BrowserKit/`, with a cut-down `Package.swift`. It records the source commit in `Vendor/BrowserKit/VENDORED_FROM`.
- Vendored files keep their MPL-2.0 headers and stay unmodified. Any change we need is a small patch in `Vendor/BrowserKit/patches/`, applied by the script, so updates stay possible.
- Mozilla's `SampleBrowser` is the reference for how to use `WebEngine`.
- Zen desktop (Gecko, MPL-2.0) is used as a reference for behaviour and concepts only; no code is reused from it.

## 4. State and data flow
- One `@Observable` `BrowserState` on the main actor holds the spaces, the current space, the open tab and the gesture state. Views read it; changes go through methods on it, which call pure functions in `ZenModel`.
- `ZenStore` saves after changes (debounced, about 0.5 s) and on going to the background.
- Web views live in `ZenWeb`'s `WebViewPool`, keyed by tab id. They are created when needed, can be unloaded under memory pressure, and are restored from saved navigation state.

## 5. Key UI mechanics
- **Space pager (2A):** a horizontal paging scroll view over the spaces, with the background colour blended from the scroll offset. Vertical lists are inside each page and lock their direction.
- **Open/close transition (3A):** it animates from the tab row's frame to full screen using the tab's snapshot image, then swaps in the live web view at the end. Closing does the reverse into the row's current frame.
- **Bar gesture (4A):** a UIKit pan recognizer on the bar, bridged into SwiftUI. It produces a single `progress` value (0 to stop 2). The page scale, the stop markers and the haptics are all driven from that one value, so the animation is interruptible and stays in sync with the finger. Release logic uses distance plus velocity (spec §3.5).

## 6. Testing
- `ZenModel` and `ZenStore`: unit tests with `swift test`, which run on Linux and macOS.
- `ZenUI`: snapshot or preview tests for the screens; UI tests for the main flows (open tab, back to space, new tab, change space) on macOS CI.
- CI: GitHub Actions. Linux runs `swift test` on the pure packages; macOS runs the full app build and UI tests. The macOS runners and their minutes need checking on this repo.
