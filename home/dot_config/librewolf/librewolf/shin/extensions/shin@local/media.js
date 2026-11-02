// Tells the page's media session where the playing <video>/<audio> is, so MPRIS
// (and waybar's now-playing, ~/.config/waybar/scripts/media.sh) always has the
// position and length. Most sites set it rarely or never, and after a resume the
// browser reports 0 until they do.
"use strict";

let lastTick = 0;

function sync(event) {
  const media = event.target;
  // Muted ones are previews and ads (YouTube's thumbnails), not what's playing.
  if (!(media instanceof HTMLMediaElement) || media.muted) return;
  if (event.type === "timeupdate") {
    const now = Date.now();
    if (now - lastTick < 1000) return;
    lastTick = now;
  }
  const duration = media.duration;
  if (!(duration > 0) || duration === Infinity) return; // live streams have no length
  try {
    // Without this the browser keeps moving the position along while paused.
    navigator.mediaSession.playbackState = media.paused ? "paused" : "playing";
    navigator.mediaSession.setPositionState({
      duration,
      position: Math.min(media.currentTime, duration),
      playbackRate: media.playbackRate || 1,
    });
  } catch {}
}

// Media events don't bubble, but a capturing listener on the document sees them all.
for (const type of ["loadedmetadata", "durationchange", "play", "playing", "pause", "seeked", "ratechange", "timeupdate"]) {
  document.addEventListener(type, sync, true);
}
