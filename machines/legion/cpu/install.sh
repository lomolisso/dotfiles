#!/usr/bin/env bash
# Intel CPU microcode, loaded at boot by mkinitcpio's microcode hook. pacman's hook
# rebuilds the boot image when this updates.
set -euo pipefail
sudo pacman -S --needed --noconfirm intel-ucode
