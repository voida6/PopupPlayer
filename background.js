// Toolbar click -> inject togglePip into the active tab.
// The action click supplies the user activation that requestPictureInPicture()
// requires, and the injected function inherits that gesture.

chrome.action.onClicked.addListener((tab) => {
  if (!tab || tab.id == null) return;
  chrome.scripting
    .executeScript({ target: { tabId: tab.id }, func: togglePip })
    .catch((err) => console.warn("PopupPlayer: injection failed", err));
});

// Self-contained: this function is serialized and run in the page, so it cannot
// reference anything outside its own body.
function togglePip() {
  // Already floating -> toggle off.
  if (document.pictureInPictureElement) {
    document.exitPictureInPicture().catch((err) =>
      console.warn("PopupPlayer: exit failed", err)
    );
    return;
  }

  const area = (v) => {
    const r = v.getBoundingClientRect();
    return r.width * r.height;
  };

  const videos = Array.from(document.querySelectorAll("video")).filter(
    (v) => !v.disablePictureInPicture
  );
  if (videos.length === 0) {
    console.warn("PopupPlayer: no video found on this page");
    return;
  }

  // Prefer a video that is actually playing; fall back to the largest one.
  const playing = videos.filter((v) => !v.paused && v.readyState >= 2);
  const pool = playing.length ? playing : videos;
  const video = pool.sort((a, b) => area(b) - area(a))[0];

  // Surface controls in the PiP window via the Media Session API. Chrome renders
  // a button for each registered action handler.
  const ms = navigator.mediaSession;
  if (ms) {
    const set = (action, handler) => {
      try {
        ms.setActionHandler(action, handler);
      } catch (err) {
        /* some actions are unsupported on some browsers */
      }
    };
    set("play", () => video.play());
    set("pause", () => video.pause());
    set("seekbackward", (details) => {
      const step = (details && details.seekOffset) || 10;
      video.currentTime = Math.max(0, video.currentTime - step);
    });
    set("seekforward", (details) => {
      const step = (details && details.seekOffset) || 10;
      const end = isFinite(video.duration) ? video.duration : Infinity;
      video.currentTime = Math.min(end, video.currentTime + step);
    });
  }

  video.requestPictureInPicture().catch((err) =>
    console.warn("PopupPlayer: requestPictureInPicture failed", err)
  );
}
