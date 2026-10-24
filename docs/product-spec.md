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
| **Pinned tab** | A tab kept above the divider. It remembers its *pinned URL*, so it can be reset to it. Essentials remember a pinned URL too. |
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
1. Header: space icon, space name, and an options button (rename, icon, colour, delete, new space, new folder). New folder asks for a name and creates an empty folder at the end of the pinned section.
2. Essentials grid: 4 columns of icon tiles. It stays in place under the header: only the pinned section and the tabs below it scroll. *(proposal)*
3. Pinned section: pinned tabs and folders. Tapping a folder expands or collapses it. A collapsed folder shows how many tabs it holds.
4. Divider.
5. Regular tabs. The active tab is highlighted.
6. Space page indicator (one dot per space, the current one wider).
7. Bottom bar: a "Search or enter address" field, which opens a new tab. There is no **+** button: the field and the bar gesture already open a new tab.

Site icons:
- Essentials and tab rows show the page's icon. When a page finishes loading, the app takes the largest icon the page declares (an Apple touch icon or an icon link; SVG icons are skipped), or the site's `/favicon.ico` if it declares none. *(proposal)*
- The icon is saved with the tab, so it shows again after a relaunch without opening the page. It is kept while the tab stays on the same site, and dropped when the tab goes to another site until that site's icon is found. A pinned tab or an Essential keeps the icon of its pinned site wherever it navigates; "Replace pinned URL with current URL" on another site drops it until the new site's icon is found.
- Until the icon is known and loaded, or if it can't be loaded, the tile shows the first letter of the title or site on the space colour.

Actions on a tab row:
- Tap: open the tab (3.4).
- Double-tap a pinned tab or an Essential: open it on its pinned URL, wherever it had navigated to. A single tap on these waits a moment, to tell it from a double tap.
- Rows don't swipe: a sideways swipe always changes space (3.3). Closing and unloading are in the long-press menu.
- Long-press: context menu with Pin/Unpin, Move to folder, Move to space, Add to Essentials, Duplicate, Close.
  - A pinned tab's menu also has Unload: it frees the page and the tab stays in the list.
  - Move to folder lists every folder of the space, collapsed or not, and "New folder…", which asks for a name, creates the folder at the end of the pinned section and moves the tab into it. A regular tab moved into a folder becomes pinned. *(proposal)*
  - Move to space is hidden when there is only one space.
  - Duplicate puts the copy right after the original, in the same place. *(proposal)*
- Long-press on an Essential: Remove from Essentials (the tab goes to the top of the current space's regular tabs), Duplicate, Close. *(proposal)*
- Long-press on a pinned tab or an Essential also offers "Go back to pinned page" and "Replace pinned URL with current URL"; both are disabled while the tab shows its pinned URL. A tab that leaves the pinned section or Essentials forgets its pinned URL. Pinned tabs and Essentials saved before pinned URLs existed have none; on launch they take the URL they show as their pinned URL.
- Long-press on a folder: Rename, Delete folder (its tabs and folders take its place). *(proposal)*
- Long-press then drag: reorder, including into or out of folders and across the divider. Dragging across the divider pins or unpins the tab.
  - Dropping a tab on a row puts it right before that row, in the same list (Essentials, a folder, the pinned section or the regular tabs). Dropping it on a folder puts it at the end of that folder; on the divider, or anywhere else in the pinned section, at the end of the pinned section; anywhere else in the Essentials grid, at the end of Essentials; below the last regular tab, at the end of the regular tabs. *(proposal)*
  - An empty Essentials grid shows a dashed "Drag a tab here to add it to Essentials" tile, and an empty pinned section a dashed "Drag a tab here to pin it" row, so there is always somewhere to drop. *(proposal)*
  - Folders can't be dragged yet. *(open)*

Automatic clean-up of regular tabs:
- A regular tab that hasn't been opened for a set time is closed automatically. Pinned tabs, tabs in folders and Essentials are never closed this way.
- The delay is a setting: 12 h, 24 h, 7 days or Never. The default is 24 h. *(proposal, tune)*
- Closed tabs go to a "Recently closed" list, so they can be restored.
- The header's options menu has "Recently closed" (a sheet listing them, most recent first; tapping one reopens it at the top of the current space) and "Close inactive tabs after" (12 hours, 24 hours, 7 days, Never). *(proposal)*

### 3.3 Changing space (design 2A)
- Swipe left or right anywhere on the space screen to go to the next or previous space.
- The list follows the finger 1:1, like pages. Release past about half the width, or with a fast flick, to change space; otherwise it snaps back.
- The background colour blends between the two spaces' colours during the swipe. The dots use the blended colour too.
- Scrolling direction locks after the first few points of movement, so a vertical scroll never changes space by accident.
- These three behaviours come from the system's paging scroll view, so their thresholds are the system's, not ours. If testing on a device shows they need tuning, we will replace it with our own gesture. *(tune)*
- The Essentials grid doesn't move during the swipe, since it is shared by all spaces: only the header, pinned section and tabs slide (asked for on 2026-10-24). Swiping to the "New space" page fades the grid out. *(proposal)*
- At the first space the swipe resists (rubber band). Swiping past the last space shows a "New space" page. *(proposal)*
- Settling on the "New space" page opens the new space sheet at once (name, icon, colour). Creating the space shows it; cancelling or swiping the sheet away creates nothing and swipes back to the last space.

### 3.4 Opening a tab (design 3A + validated change)
- Tapping a tab row makes the row grow into the full-screen page (zoom transition, about 0.35 s spring). *(tune)*
- The opened page is **full screen**. The only controls are a **bottom bar** that shows the **tab title** with the **domain** under it, and a **"…" button** to its right. *(position: proposal)*
- Tapping the bar opens address editing (full URL, keyboard, suggestions). There is no Cancel button: tapping the page closes the field without loading anything (asked for on 2026-10-24).
  - On a regular tab, the new address loads in the same tab. On a pinned tab or an Essential, it opens in a new tab at the top of the current space's regular tabs, and the pinned tab or Essential keeps its page.
- On a pinned tab or an Essential, double-tapping the bar goes back to the pinned URL.
- The "…" button opens the page menu (decided 2026-10-24): **Back**, **Forward**, **Reload**, **Share**, **Copy link**, **Find on page** and **Request desktop site**.
  - Back and Forward are greyed out when the page has nothing to go back or forward to. A new tab with no address shows only Back, Forward and Reload, greyed out.
  - Find on page opens the system find bar. *(proposal)*
  - Request desktop site reloads the page as the desktop version; the item then reads **Request mobile site** and switches back. The choice holds for this tab's page until the page is freed (§4); it isn't saved. *(proposal)*
- Pulling the page down when it is already at the top reloads it, with the system's refresh spinner, as in Safari (asked for on 2026-10-24). How far to pull is the system's.
- The page uses the whole screen, as in Safari (asked for on 2026-10-24):
  - The page fills the screen from the top edge to the bottom edge, with no band above or below it, and the bar floats over it.
  - At the top of the page, its start is fully visible below the status bar, and the status bar area shows the page's own background colour (asked for on 2026-10-24). Once the page scrolls down, it runs under the status bar, which is blurred over it.
  - The page can always scroll far enough that its end clears the bar, so the bar never hides part of it for good.
  - When the finger scrolls the page down (about 24 pt) *(tune)*, the bar minimizes to a slim, translucent, title-only strip without the "…" button. Scrolling back up (about 24 pt) *(tune)*, reaching the top of the page, loading a new page or tapping the strip expands the bar again. A page that fits on the screen keeps the bar expanded, and so does address editing.
  - The bar gesture (§3.5) works on the minimized strip too.
- Swipe sideways anywhere on the page to move in its history: to the right goes back, to the left goes forward (asked for on 2026-10-24).
  - The page follows the finger when there is a page to go to that way, and doesn't move otherwise. Release past about 100 pt, or with a fast flick (about 800 pt/s), to go there; otherwise the page snaps back. *(tune)*
  - The swipe doesn't start when the page itself can still scroll sideways in that direction (a page wider than the screen, or zoomed in). When there is history that way, a website's own sideways swipes, such as photo carousels or maps, are taken over by this swipe.
  - WebKit's own swipe from the left or right screen edge, as in Safari, stays on.

### 3.5 The bar gesture: back to the space, or a new tab (design 4A)
The upward drag starts **on the page's bottom bar**, never at the screen edge (the bottom edge belongs to the iOS Home gesture).

| Drag distance (up) | Feedback | On release |
|---|---|---|
| < stop 1 (≈ 120 pt) *(tune)* | The page shrinks and follows the finger | Snaps back to the page |
| stop 1 → stop 2 | Light haptic at stop 1; the "Space" marker lights up | **Back to the space**: the page shrinks into its tab row (3A in reverse) |
| ≥ stop 2 (≈ 420 pt) *(tune)* | Haptic at stop 2; the "New tab" marker lights up | **New tab**: an empty tab is created and the new tab overlay opens with the keyboard (§3.6) |

- The animation is interruptible and follows the finger the whole time.
- A fast upward flick counts as "back to the space", however far it goes: a quick swipe easily passes stop 2, so a new tab needs the finger to slow down past stop 2 before letting go. *(tune)*
- New tabs go at the top of the current space's regular tabs. *(proposal)*

### 3.6 New tab
- It is reachable from the search field on the space screen and from stop 2 of the bar gesture.
- Until an address is entered, it shows only the address field, with focus, centred on the screen as an overlay over the dimmed space screen (asked for on 2026-10-24). There is no blank page and no bottom bar. How much the space is dimmed is *(tune)*.
- That address field is the space screen's search field itself: it leaves the bottom bar, moves up to the centre and takes focus, so there is never a second field at the bottom (asked for on 2026-10-24). Closing the new tab moves it back down into the bottom bar. With Reduce Motion it crossfades instead of moving (§5). The timing is *(tune)*.
- There is no Cancel button: tapping anywhere outside the field closes the new tab, which leaves nothing behind, and shows the space again.
- Entering an address loads it, and the page grows from the space screen's search field into the full-screen page (§3.4).
- It will also show suggestions from history, open tabs and a search engine.
- Text that isn't a web address is searched with **Google** (decided 2026-10-24). A setting to change the engine will come later.

### 3.7 Space management
- Create, rename, set the icon and colour, reorder, and delete a space. Deleting a space asks what to do with its tabs: close them, or move them to another space.
- Everything is in the header's options menu: Edit space, New space, Move left, Move right, Delete space. Moving left or right is how spaces are reordered for now. *(proposal)*
- Edit space and New space open a sheet with the name, the icon (an emoji or a letter) and the colour (system colour picker). A space needs a name. A blank icon becomes the name's first letter. *(proposal)*
- A new space starts with the next of the mockups' colours (Personal, Work, Research), in turn. It goes after the existing spaces and is shown at once. *(proposal)*
- The "New space" page after the last space (§3.3) opens the same sheet as soon as the swipe settles on it.

## 4. Web engine requirements
- WebKit (`WKWebView`) is required by App Store rules outside the EU. The app uses it everywhere.
- Background tabs can be unloaded to save memory and restored from saved navigation state when opened.
  - Today: a closed tab's page is freed at once, and on a low-memory warning every page but the open one is freed. A freed page reloads its URL when opened; its back/forward history isn't saved yet.
- A snapshot image is kept for each tab and used during transitions, so an animation never waits for a page to load.

## 5. Accessibility
- Every gesture has a button or menu alternative: the bar has VoiceOver actions "Back to space" and "New tab"; changing space has previous/next actions; double-tapping a pinned tab or an Essential has "Go back to pinned page" in its menu. Going back and forward in a page's history will have buttons in the page's "…" menu.
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
- **Icon:** the app uses Zen desktop's icon for now. Its repository is MPL-2.0 and publishes no separate trademark or logo policy that we found (2026-10-24). Before any App Store release, the icon needs the same check with the Zen project as the name.

## 8. Open questions
None at the moment.
