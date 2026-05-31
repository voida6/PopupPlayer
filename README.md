# PopupPlayer

A tiny Chrome/Edge (Manifest V3) extension that pops the video on the current
page into the browser's native **Picture-in-Picture** floating window with one
click — on any site that has an HTML5 `<video>`.

## What it does

- **Works on any site with a video.** Click the toolbar icon (or press
  **Alt+T**) once to pop the active video into a floating window; do it again to
  close it. The shortcut can be changed at `chrome://extensions/shortcuts`.
- **Forces PiP even where sites disable it.** Some streaming services hide or
  disable the built-in PiP button (Netflix, for example). PopupPlayer requests
  Picture-in-Picture programmatically so it still pops out. This only relocates
  the window — it never copies or records the stream, so DRM-protected playback
  is unaffected.
- **Uses the browser's default player.** The floating window is Chrome's stock
  Picture-in-Picture UI — whatever controls the browser and the site provide on
  their own (play/pause, seek, etc.). PopupPlayer adds no controls of its own.

## How it works

- `manifest.json` — MV3 manifest. No host permissions; just `activeTab` +
  `scripting`, granted for the current tab when you invoke the extension. The
  `commands` entry binds the Alt+T shortcut to the action.
- `background.js` — when the action fires (toolbar click or Alt+T), injects a
  self-contained `togglePip` function into the active tab. It picks the best
  `<video>` (a playing one if available, otherwise the largest) and requests
  Picture-in-Picture (clearing `disablePictureInPicture` first, so it still
  works on sites that suppress it).

## Install (load unpacked)

1. Open `chrome://extensions` (or `edge://extensions`).
2. Enable **Developer mode** (top right).
3. Click **Load unpacked** and select this folder.
4. Pin the PopupPlayer icon, open a page with a video, and click it.

## Planned / next

- Optional [Document Picture-in-Picture](https://developer.chrome.com/docs/web-platform/document-picture-in-picture)
  mode for a fully custom control bar (Chrome 116+).
- Smarter `<video>` selection on pages that embed several.
