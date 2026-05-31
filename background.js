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

  // Include videos that the site marked disablePictureInPicture (e.g. Netflix);
  // we re-enable it on the chosen video below before requesting PiP.
  const videos = Array.from(document.querySelectorAll("video"));
  if (videos.length === 0) {
    console.warn("PopupPlayer: no video found on this page");
    return;
  }

  // Prefer a video that is actually playing; fall back to the largest one.
  const playing = videos.filter((v) => !v.paused && v.readyState >= 2);
  const pool = playing.length ? playing : videos;
  const video = pool.sort((a, b) => area(b) - area(a))[0];

  // Some sites set this to suppress PiP; clear it before requesting.
  video.disablePictureInPicture = false;

  video.requestPictureInPicture().catch((err) =>
    console.warn("PopupPlayer: requestPictureInPicture failed", err)
  );
}
