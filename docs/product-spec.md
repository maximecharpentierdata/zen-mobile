# Zen for iPhone: product spec

Status: draft for review.
Design reference: the validated mockups on the design canvas (see [design.md](design.md)).

Some values in this document (thresholds, durations, positions) are **initial proposals**, marked *(tune)*. They need testing on a device and can change.

## 1. Goal

Zen for iPhone brings the Zen Browser way of working to the phone. Tabs are a vertical list, organised in **Spaces**, with **pinned tabs**, **folders** and **Essentials**. The app is a space-first browser: you land on a space, not on a web page.

## 2. Concepts and data model

| Concept | Definition |
|---|---|
| **Space** | A named group of tabs with its own icon and colour. The user has 1 or more spaces, in an order they choose. |
| **Essentials** | A grid of favourite sites shown at the top of the space screen as icons, without titles. Essentials are **shared by all spaces**, as in Zen desktop. |
| **Pinned tab** | A tab kept above the divider. It remembers its *pinned URL*, so it can be reset to it. |
| **Folder** | A named, collapsible group in the pinned section. Folders can be nested. |
| **Regular tab** | A tab below the divider. |
| **Tab** | A web page with its URL, title, favicon, last-access date, saved navigation state and a snapshot image. |

Space structure:

```
Space
├─ pinned: [PinnedItem]       PinnedItem = Tab | Folder(children: [PinnedItem])
└─ regular: [Tab]
Essentials: [Tab]             (shared by all spaces)
```

Rules:
- A tab belongs to exactly one place: Essentials, the pinned tree of one space, or the regular list of one space.
- There is always at least one space. Deleting the last space is not allowed.
- Order matters everywhere and is kept by the user.

## 3. Screens and interactions

### 3.1 Launch
- The app opens **full screen on the space screen** of the last space used, not on a web page.
- On the very first launch, it creates one space called "Personal" with no tabs.

### 3.2 Space screen (design 1A)
From top to bottom:
1. Header: space icon, space name, and an options button (rename, icon, colour, delete, new space).
2. Essentials grid: 4 columns of icon tiles.
3. Pinned section: pinned tabs and folders. Tapping a folder expands or collapses it. A collapsed folder shows how many tabs it holds.
4. Divider.
5. Regular tabs. The active tab is highlighted.
6. Space page indicator (one dot per space, the current one wider).
7. Bottom bar: a "Search or enter address" field and a **+** (new tab) button.

Actions on a tab row:
- Tap: open the tab (3.4).
- Swipe the row left: close it (regular tabs) or unload it (pinned tabs, which stay in the list).
- Long-press: context menu with Pin/Unpin, Move to folder, Move to space, Add to Essentials, Duplicate, Close.
  - Move to folder lists every folder of the space, collapsed or not, and "New folder…", which asks for a name, creates the folder at the end of the pinned section and moves the tab into it. A regular tab moved into a folder becomes pinned. *(proposal)*
  - Move to space is hidden when there is only one space.
  - Duplicate puts the copy right after the original, in the same place. *(proposal)*
- Long-press on an Essential: Remove from Essentials (the tab goes to the top of the current space's regular tabs), Duplicate, Close. *(proposal)*
- Long-press on a folder: Rename, Delete folder (its tabs and folders take its place). *(proposal)*
- Long-press then drag: reorder, including into or out of folders and across the divider. Dragging across the divider pins or unpins the tab.
  - Dropping a tab on a row puts it right before that row, in the same list (Essentials, a folder, the pinned section or the regular tabs). Dropping it on a folder puts it at the end of that folder; on the divider, at the end of the pinned section; below the last regular tab, at the end of the regular tabs. *(proposal)*
  - Folders can't be dragged yet. *(open)*

Automatic clean-up of regular tabs:
- A regular tab that hasn't been opened for a set time is closed automatically. Pinned tabs, tabs in folders and Essentials are never closed this way.
- The delay is a setting: 12 h, 24 h, 7 days or Never. The default is 24 h. *(proposal, tune)*
- Closed tabs go to a "Recently closed" list, so they can be restored.
- The header's options menu has "Recently closed" (a sheet listing them, most recent first; tapping one reopens it at the top of the current space) and "Close inactive tabs after" (12 hours, 24 hours, 7 days, Never). *(proposal)*

### 3.3 Changing space (design 2A)
- Swipe left or right anywhere on the space screen to go to the next or previous space.
- The list follows the finger 1:1, like pages. Release past about half the width, or with a fast flick, to change space; otherwise it snaps back.
- The background colour blends between the two spaces' colours during the swipe. The dots and the bottom bar use the blended colour too.
- Scrolling direction locks after the first few points of movement, so a vertical scroll never changes space by accident.
- These three behaviours come from the system's paging scroll view, so their thresholds are the system's, not ours. If testing on a device shows they need tuning, we will replace it with our own gesture. *(tune)*
- At the first space the swipe resists (rubber band). Swiping past the last space shows a "New space" page. *(proposal)*

### 3.4 Opening a tab (design 3A + validated change)
- Tapping a tab row makes the row grow into the full-screen page (zoom transition, about 0.35 s spring). *(tune)*
- The opened page is **full screen**. The only control is a **bottom bar** that shows the **tab title** with the **domain** under it.
- Tapping the bar opens address editing (full URL, keyboard, suggestions).
- When the page scrolls down, the bar shrinks to a slim title-only strip; scrolling up restores it. *(proposal)*

### 3.5 The bar gesture: back to the space, or a new tab (design 4A)
The upward drag starts **on the page's bottom bar**, never at the screen edge (the bottom edge belongs to the iOS Home gesture).

| Drag distance (up) | Feedback | On release |
|---|---|---|
| < stop 1 (≈ 120 pt) *(tune)* | The page shrinks and follows the finger | Snaps back to the page |
| stop 1 → stop 2 | Light haptic at stop 1; the "Space" marker lights up | **Back to the space**: the page shrinks into its tab row (3A in reverse) |
| ≥ stop 2 (≈ 280 pt) *(tune)* | Haptic at stop 2; the "New tab" marker lights up | **New tab**: an empty tab is created and the address field opens with the keyboard |

- The animation is interruptible and follows the finger the whole time.
- A fast upward flick that ends before stop 2 counts as "back to the space". *(tune)*
- New tabs go at the top of the current space's regular tabs. *(proposal)*

### 3.6 New tab
- It is reachable from the **+** button on the space screen, from the search field on the space screen, and from stop 2 of the bar gesture.
- It shows an address field with focus, then suggestions from history, open tabs and a search engine.
- Text that isn't a web address is searched with **Google** (decided 2026-10-24). A setting to change the engine will come later.

### 3.7 Space management
- Create, rename, set the icon and colour, reorder, and delete a space. Deleting a space asks what to do with its tabs: close them, or move them to another space.
- Everything is in the header's options menu: Edit space, New space, Move left, Move right, Delete space. Moving left or right is how spaces are reordered for now. *(proposal)*
- Edit space and New space open a sheet with the name, the icon (an emoji or a letter) and the colour (system colour picker). A space needs a name. A blank icon becomes the name's first letter. *(proposal)*
- A new space starts with the next of the mockups' colours (Personal, Work, Research), in turn. It goes after the existing spaces and is shown at once. *(proposal)*
- The "New space" page after the last space (§3.3) opens the same sheet.

## 4. Web engine requirements
- WebKit (`WKWebView`) is required by App Store rules outside the EU. The app uses it everywhere.
- Background tabs can be unloaded to save memory and restored from saved navigation state when opened.
- A snapshot image is kept for each tab and used during transitions, so an animation never waits for a page to load.

## 5. Accessibility
- Every gesture has a button or menu alternative: the bar has VoiceOver actions "Back to space" and "New tab"; changing space has previous/next actions.
- With Reduce Motion on, the zoom and shrink transitions become crossfades.
- Dynamic Type is supported on the space screen and the bar.

## 6. Out of scope for v1
Sync (including with Zen desktop), private browsing, extensions, split view, Glance, compact mode, iPad layout, themes beyond the space colour, and import from other browsers.

## 7. Decisions on earlier open questions (2026-10-24)
- **Essentials:** shared by all spaces, as in Zen desktop (§2).
- **Sync with Zen desktop:** not in v1. Zen added Spaces sync through Mozilla accounts in 2026; its data format and whether a third-party app can use it are still to research before v2.
- **Automatic clean-up of regular tabs:** yes (§3.2). The delay values are proposals.
- **Private browsing:** not in v1.
- **Licence:** MPL-2.0 for our own code (see `LICENSE`).
- **Name:** "Zen" stays the working name for now. Before any App Store release, we need to check with the Zen project.

## 8. Open questions
None at the moment.
