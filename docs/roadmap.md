# Roadmap

Each milestone ends with a PR that builds, passes CI and can be tried.

| # | Milestone | Content | Spec |
|---|---|---|---|
| M0 | Skeleton | `project.yml`, empty app, packages, swift-format/SwiftLint configs, CI (Linux `swift test` + macOS build), vendoring script | architecture §1–3, §6 |
| M1 | Model and store | `ZenModel` types and tree operations; `ZenStore` JSON persistence; full unit tests | spec §2 |
| M2 | Space screen | Static 1A screen from the model: Essentials, pinned tabs, folders, divider, tabs, bottom bar | spec §3.2 |
| M3 | Web pages | `ZenWeb` over WebEngine; open a tab full screen with the title/domain bar; address editing; new tab | spec §3.4, §3.6, §4 |
| M4 | Bar gesture | Drag up with two stops, haptics, the shrink-into-row transition (3A both ways) | spec §3.4, §3.5 |
| M5 | Spaces | Paged swipe between spaces with colour blending; create/rename/delete spaces | spec §3.3, §3.7 |
| M6 | Tab management | Swipe to close, context menu, drag to reorder, folders, pin/unpin, Essentials | spec §3.2 |
| M7 | Polish | Accessibility alternatives, Reduce Motion, memory/unloading, performance on older iPhones | spec §4–5 |
| M8 | TestFlight | App icon, name, privacy details, first TestFlight build | open questions Q5–Q6 |
