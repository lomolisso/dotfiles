#!/usr/bin/env bash
# Installs this computer's machine-specific setup: `install.sh` for every category
# or `install.sh dual-boot nvidia` for some. Separate from the main dotfiles, so
# packages here come straight from pacman and metapac doesn't know about them
# (never run `metapac clean`: it would remove them, including the boot loader).
# Safe to rerun.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

[[ $# -gt 0 ]] && categories=("$@") || categories=(cpu nvidia display dual-boot)
for category in "${categories[@]}"; do
  [[ -x $here/$category/install.sh ]] || { echo "No category '$category' in $here" >&2; exit 1; }
  printf '\n=== %s ===\n' "$category"
  "$here/$category/install.sh"
done
