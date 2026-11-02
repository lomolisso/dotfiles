# legion

This computer's machine-specific setup, kept out of the main dotfiles: a Lenovo
Legion desktop (Intel CPU, NVIDIA GPU, MSI 1440p 240 Hz monitor), dual-booting Windows.

```sh
~/dotfiles/machines/legion/install.sh                # every category
~/dotfiles/machines/legion/install.sh nvidia display # some of them
```

| Category | What it sets up |
|---|---|
| `cpu` | `intel-ucode` |
| `nvidia` | `nvidia-open`, `libva-nvidia-driver`, niri's VRAM profile |
| `display` | monitor mode, in `~/.config/niri/local.kdl` |
| `dual-boot` | GRUB menu and theme, `reboot-to-windows`, `bt-windows-keys`, the power menu's Windows entry |

Packages here come straight from pacman, so regular system updates keep them
current. See the main README's warning about `metapac clean`.

`grub.cfg` boots Arch and Windows by partition UUID; on a new disk layout, update
them (`lsblk -f`). The installer stops with a message if they don't match.

## Bluetooth with Windows

A device keeps one key per computer, and both OSes share this computer's Bluetooth
address, so pairing in one OS breaks the other. Windows owns the key:

- **Pair in Windows only.** `bt-windows-keys.service` copies a changed key into BlueZ
  on the next Arch boot, before bluetoothd starts. Windows is only ever read.
- **If a device stops connecting in either OS,** re-pair it in Windows, then boot Arch.
- **Don't remove a device in Arch.** The import updates an existing entry and can't
  create one; if it's gone, pair in Arch, then re-pair in Windows.
- **Keep Fast Startup off in Windows,** or leave Windows with Restart. While the
  registry on disk may be out of date, the import skips and tries again next boot.

Check it with `journalctl -b -u bt-windows-keys`, or `sudo bt-windows-keys --dry-run`.
Classic Bluetooth only, not LE devices.
