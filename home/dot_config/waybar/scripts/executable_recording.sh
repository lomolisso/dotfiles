#!/usr/bin/env bash
# Blinking dot in waybar while ~/.local/bin/screenrecord is recording.
if pgrep -f '^gpu-screen-recorder ' >/dev/null; then
  echo '{"text":"󰑊","tooltip":"Recording. Click (or Mod+Alt+R) to stop.","class":"active"}'
else
  echo '{"text":""}'
fi
