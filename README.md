# PopupPlayer

A tiny Chrome/Edge (Manifest V3) extension that pops the video on the current
page into the browser's native **Picture-in-Picture** floating window with one
click — on any site that has an HTML5 `<video>`.

## What it does

- **Works on any site with a video.** Click the toolbar icon once to pop the
  active video into a floating window, click again to close it.
- **Forces PiP even where sites disable it.** Some streaming services hide or
  disable the built-in PiP button (Netflix, for example). PopupPlayer requests
  Picture-in-Picture programmatically so it still pops out. This only relocates
  the window — it never copies or records the stream, so DRM-protected playback
  is unaffected.
- **Adds controls where supported.** On sites that expose their media to the
  browser (YouTube and many others), the PiP window also shows
  **play / pause / 10s-back / 10s-forward** buttons, wired up through the
  [Media Session API](https://developer.mozilla.org/docs/Web/API/Media_Session_API).
  No custom UI to maintain — the browser draws a button for each registered
  action.

## How it works

- `manifest.json` — MV3 manifest. No host permissions; just `activeTab` +
  `scripting`, granted for the current tab when you click the toolbar button.
- `background.js` — on toolbar click, injects a self-contained `togglePip`
  function into the active tab. It picks the best `<video>` (a playing one if
  available, otherwise the largest), wires up the Media Session controls, and
  requests Picture-in-Picture.

## Install (load unpacked)

1. Open `chrome://extensions` (or `edge://extensions`).
2. Enable **Developer mode** (top right).
3. Click **Load unpacked** and select this folder.
4. Pin the PopupPlayer icon, open a page with a video, and click it.

## Planned / next

- Custom toolbar icons under `icons/`.
- Optional [Document Picture-in-Picture](https://developer.chrome.com/docs/web-platform/document-picture-in-picture)
  mode for a fully custom control bar (Chrome 116+).
- A keyboard shortcut to toggle without the toolbar.
- Smarter `<video>` selection on pages that embed several.
