# macOS Settings Checklist

Everything this repo changes about macOS, written as things to **look at**, not values to read.

`defaults read` is not a test. If Apple removes a key, the write still succeeds, the read still
returns your value, and the behaviour is simply gone — a value check reports success while the
setting does nothing. The only honest check is whether the machine still behaves the way you
asked it to.

Walk this after every macOS upgrade. Grouped by where you look, so it is one pass per area.

**Last confirmed working:** macOS 26.0 (build 25A8353)

---

## Desktop and menu bar

- [ ] The interface is **dark**, not light.
- [ ] The **menu bar is always visible** — move the pointer to the middle of the screen and it stays.
- [ ] The wallpaper is the one from this repo, not an Apple default.
- [ ] **Nothing is on the desktop** — no drives, no files, no folders, even after saving a file to `~/Desktop`.
- [ ] **No widgets** anywhere on the desktop.
- [ ] **Click the wallpaper** — windows stay put. They must *not* slide aside to reveal the desktop.

## Dock

- [ ] The Dock is on the **left edge** of the screen.
- [ ] The Dock is **hidden** until you push the pointer to the left edge.
- [ ] Dock icons are **small** (roughly a third of the default size).
- [ ] There is **no "recent applications" section** — no separator with apps you didn't pin.
- [ ] The pinned apps appear **in this order**: System Settings, WezTerm, Google Chrome, Slack,
      Postman, Bitwarden, Notion, Notion Calendar, WhatsApp, Discord, OBS, Figma.

## Finder

Open a new Finder window with `Cmd+N`.

- [ ] It opens on your **home folder**, not Recents or iCloud.
- [ ] It opens in **List view**, not icons or columns.
- [ ] **Folders sort above files**, not mixed alphabetically.
- [ ] A **path breadcrumb** runs along the bottom of the window.
- [ ] A **status bar** below it shows "N items, X available".
- [ ] **Hidden files are visible** — you can see `.zshrc`, `.config`, `.ssh` in your home folder.
- [ ] Filenames show their **extensions** — `notes.txt`, not `notes`.
- [ ] Rename a file's extension (`notes.txt` → `notes.md`) — **no confirmation dialog** appears.
- [ ] Type in the Finder search box — the scope defaults to **the current folder**, not "This Mac".

## Keyboard

Click into any text field.

- [ ] Hold a key — it **starts repeating almost immediately** (about a quarter second).
- [ ] While repeating, characters come out **very fast**.
- [ ] Hold a vowel like `a` — you get **`aaaaaa`**, *not* the accent picker popup. This is the one
      that silently reverts most often.

## Mouse and trackpad

- [ ] Scroll down with a mouse wheel — the **content moves down** (natural scrolling is off).
- [ ] **Tap the trackpad without pressing** — it registers as a click.

## Screenshots

Press `Cmd+Shift+4` and capture any region.

- [ ] **No floating thumbnail** appears in the bottom-right corner afterwards.
- [ ] The file lands in **`~/Pictures/Screenshots`**, not on the Desktop.
- [ ] The file is a **`.png`**.
- [ ] The filename has **no date or timestamp** in it.

## Sound

- [ ] Press the volume up/down keys — **no popping feedback sound**.
- [ ] Restart the Mac — **no startup chime**. (Only testable on a real restart.)

## Login

- [ ] Log out with apps open, log back in — **the apps do not reopen**.
