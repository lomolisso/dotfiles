#!/usr/bin/env bash
# NVIDIA driver, hardware video decoding, and the niri wiki's profile that keeps
# niri from holding excess VRAM. Takes effect after a reboot.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
sudo pacman -S --needed --noconfirm nvidia-open libva-nvidia-driver
sudo install -Dm644 "$here/50-limit-free-buffer-pool-in-wayland-compositors.json" \
  /etc/nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json
