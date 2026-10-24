# Roadmap

Each milestone ends with a PR that builds, passes CI and can be tried.

| # | Milestone | Content | Spec | Status |
|---|---|---|---|---|
| M0 | Skeleton | `project.yml`, empty app, packages, swift-format/SwiftLint configs, CI (Linux `swift test` + macOS build), Claude rules | architecture §1–2, §6 | Done |
| M1 | Model and store | `ZenModel` types and tree operations; `ZenStore` JSON persistence; full unit tests | spec §2 | Done |
| M2 | Space screen | Static 1A screen from the model: Essentials, pinned tabs, folders, divider, tabs, bottom bar | spec §3.2 | Done |
| M3 | Web pages | Our thin `ZenWeb` layer (architecture §3); open a tab full screen with the title/domain bar; address editing; new tab | spec §3.4, §3.6, §4 | Done |
| M4 | Bar gesture | Drag up with two stops, haptics, the shrink-into-row transition (3A both ways) | spec §3.4, §3.5 | Done |
| M5 | Spaces | Paged swipe between spaces with colour blending; create/rename/delete spaces | spec §3.3, §3.7 | Done |
| M6 | Tab management | Close and unload from the menu (no row swipe), context menu, drag to reorder, folders, pin/unpin, Essentials | spec §3.2 | Done; dragging folders is still open |
| M7 | Polish | Accessibility alternatives, Reduce Motion, memory/unloading, performance on older iPhones | spec §4–5 | Memory, Reduce Motion and recently closed done; performance on older iPhones needs a device |
| M8 | TestFlight | App icon, name, privacy details, first TestFlight build | Check the use of the "Zen" name with the Zen project (spec §7) | |
