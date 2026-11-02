#!/usr/bin/env bash
# This computer's monitor settings: niri's main config includes local.kdl when it
# exists. niri reloads it by itself.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
install -Dm644 "$here/outputs.kdl" "$HOME/.config/niri/local.kdl"
