#!/usr/bin/env bash
# Dual boot with Windows. Safe to rerun; run it again after editing the GRUB menu
# or theme.
#  - GRUB: on a fresh install, puts GRUB on the EFI partition (/boot) and adds
#    its firmware boot entry. Always copies the menu (grub.cfg) and the VA-11
#    HALL-A theme (themes/valhalla) to /boot/grub.
#  - reboot-to-windows: one-shot boot into Windows from waybar's power menu,
#    allowed without a password.
#  - bt-windows-keys: at boot, imports Bluetooth keys that changed in Windows.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
CFG="$here/grub.cfg"
THEME="$here/themes/valhalla"

say() { printf '\n==> %s\n' "$*"; }
die() { printf '\nSTOP: %s\n' "$*" >&2; exit 1; }

say "Installing packages"
sudo pacman -S --needed --noconfirm grub efibootmgr hivex

grub-script-check "$CFG" || die "$CFG has a syntax error"

# grub.cfg finds Arch and Windows by partition UUID. Check they exist before
# copying, so a stale menu never reaches /boot.
say "Checking the partitions grub.cfg points at"
for uuid in $(grep -oP -- '--fs-uuid --set=root \K\S+' "$CFG" | sort -u); do
  dev=$(lsblk -rno PATH,UUID | awk -v u="$uuid" '$2 == u { print $1 }')
  [[ -n $dev ]] || die "no partition with UUID $uuid; update it in $CFG (lsblk -f lists them)"
  echo "    $uuid -> $dev"
done
[[ -f /boot/EFI/Linux/arch-linux.efi ]] || die "Arch's kernel image /boot/EFI/Linux/arch-linux.efi is missing"

if [[ ! -f /boot/EFI/GRUB/grubx64.efi ]]; then
  say "Installing GRUB to /boot and adding its firmware boot entry (first in boot order)"
  sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
fi

say "Copying the GRUB menu and theme to /boot/grub"
sudo install -Dm644 "$CFG" /boot/grub/grub.cfg
sudo rm -rf /boot/grub/themes/valhalla
sudo install -d /boot/grub/themes/valhalla
sudo install -m644 "$THEME"/* /boot/grub/themes/valhalla/
[[ -f /boot/grub/grubenv ]] || sudo grub-editenv /boot/grub/grubenv create
cmp -s "$CFG" /boot/grub/grub.cfg || die "/boot/grub/grub.cfg doesn't match $CFG"

say "Installing reboot-to-windows"
sudo install -o root -g root -m755 "$here/reboot-to-windows" /usr/local/bin/reboot-to-windows
rule=$(mktemp)
printf '%s ALL=(root) NOPASSWD: /usr/local/bin/reboot-to-windows\n' "$USER" > "$rule"
sudo visudo -cqf "$rule"
sudo install -o root -g root -m440 "$rule" /etc/sudoers.d/reboot-to-windows
rm -f "$rule"
install -Dm644 "$here/powermenu-windows" "$HOME/.config/powermenu.d/windows"

say "Installing bt-windows-keys"
sudo install -o root -g root -m755 "$here/bt-windows-keys" /usr/local/bin/bt-windows-keys
sudo install -o root -g root -m644 "$here/bt-windows-keys.service" /etc/systemd/system/bt-windows-keys.service
sudo systemctl daemon-reload
sudo systemctl enable bt-windows-keys.service
# The first run records Windows' current keys, so only later changes get imported.
sudo /usr/local/bin/bt-windows-keys || echo "    bt-windows-keys couldn't read Windows; it tries again each boot"

say "Done"
