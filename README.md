# dotfiles

Arch + niri, themed "shin": OLED black, greys and wine red, from the wallpaper.
Configs: [chezmoi](https://www.chezmoi.io/). Packages: [metapac](https://github.com/ripytide/metapac).

These dotfiles are machine-agnostic. Anything tied to one computer lives in `machines/`.

## Install (blank Arch)

1. Base system with archinstall: a normal user with sudo, NetworkManager, and whichever
   bootloader and graphics driver you like. These dotfiles don't touch either.
2. Boot it, log in as your user, then:
   ```sh
   curl -fsSL https://raw.githubusercontent.com/lomolisso/dotfiles/main/install.sh | bash
   ```
   It asks for your sudo password and Bitwarden email once, then runs unattended: updates
   the system, sets up Rust, clones this repo to `~/dotfiles`, deploys `home/`, bootstraps
   paru + metapac, installs every package (services are enabled by metapac hooks), applies
   the system settings (greetd, zram, firewall), and installs VS Code extensions, LibreWolf
   add-ons, Claude Code and herdr. Safe to rerun.
3. Reboot (greetd/tuigreet starts niri).

### After the first login

| What | How |
|---|---|
| Bitwarden | `rbw login`, `rbw sync` (Super+P picks passwords) |
| SSH | personal hosts go in `~/.ssh/config.d/`; password logins listed in `~/.config/rbw-askpass/hosts` come from Bitwarden |
| Spotify | Spotify app ID in `~/.config/spotify-player/client_id` (untracked), then `spotify_player authenticate` |
| Vesktop, LibreWolf | log in (LibreWolf: Bitwarden extension too) |

Accounts and credentials (aerc `accounts.conf`, nchat, gurk, tokens) stay out of the repo.

## Layout

```
install.sh   the installer
home/        chezmoi source, deployed to ~ (packages: home/dot_config/metapac/groups/)
system/      outside $HOME, installed by install.sh: greetd config, zram config
machines/    one folder per computer, each broken into categories with its own installer
```

### Machine-specific setup

Not part of the main install. Each `machines/<computer>/install.sh` installs that computer's
categories (say, GPU driver, monitor, dual boot); `machines/legion` is mine and an example.
Packages there come straight from pacman, so metapac doesn't track them, and **`metapac clean`
would uninstall them**, possibly including the boot loader. Don't run it on such a machine.

The main config has a few optional spots for machines to fill in, so it never needs to
know about them:

| Spot | Used for |
|---|---|
| `~/.config/niri/local.kdl` | monitors, or any other niri setting |
| `~/.config/powermenu.d/*` | extra power menu entries, one per line: `label<TAB>command` |
| `~/.ssh/config.d/*` | SSH hosts |
| `~/.config/rbw-askpass/hosts` | SSH logins whose password comes from Bitwarden |

The bar's GPU widgets only appear when `nvidia-smi` works.

## Theme

| | |
|---|---|
| backgrounds | `#000000` (OLED black); panels `#1e1e1e` `#2a2a2a` `#393939` |
| text | `#e9e9e9` `#cfcfcf` `#989898` `#5c5c5c` |
| wine | `#8c1625`: borders, desktop accents, highlights |
| bright wine | `#cb4d66`: hover, TUI accents |
| gradient | `#750017` → `#8c1625` → `#a8304a` → `#cb4d66` → `#d5909e` (graphs, cava) |
| other hues | neon, in syntax and file types: green `#a2ff33`, yellow `#ffb31a`, blue `#668aff`, magenta `#d95cff`, cyan `#1aceff`; bright `#c5ff80` `#ffd480` `#a8bdff` `#eba8ff` `#75e2ff` |
| font | JetBrainsMono Nerd Font |

Wallpaper `~/Pictures/wallpapers/shin.jpg`; ghostty colors from it via matugen (`~/.config/matugen`).

## Packages

| group | |
|---|---|
| base | base base-devel linux linux-firmware mkinitcpio dosfstools zram-generator sudo git wget nano vim smartmontools pacman-contrib chezmoi paru metapac |
| hardware | sof-firmware bluez bluez-utils bluetui |
| audio | pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber gst-plugin-pipewire libpulse |
| network | networkmanager wpa_supplicant ufw |
| niri | niri xorg-xwayland xwayland-satellite xorg-xauth xdg-desktop-portal-gnome xdg-utils qt6-wayland seatd wl-clipboard grim slurp greetd greetd-tuigreet |
| desktop | waybar rofi mako awww swayosd cliphist wl-clip-persist gpu-screen-recorder matugen wttrbar hyprlock hypridle playerctl rbw rofi-rbw wtype libnotify xdg-user-dirs |
| terminal | ghostty xdg-terminal-exec fish starship helix zellij yazi ffmpeg 7zip jq poppler imagemagick resvg chafa fastfetch btop htop dust eza bat zoxide fd ripgrep fzf atuin tealdeer ouch lazygit wiremix gurk aerc nchat-bin |
| media | spotify-player cava mpd rmpc mpv mpv-mpris yt-dlp imv zathura zathura-pdf-mupdf |
| apps | librewolf vesktop-bin |
| fonts | noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-dejavu ttf-jetbrains-mono-nerd ttf-ms-fonts |
| dev | rustup go cmake ninja ty ruff clang gopls verible-bin jdk21-openjdk sbt coursier (+ metals) bash-language-server shellcheck marksman harper taplo-cli vscode-json-languageserver yaml-language-server tinymist typst lldb delve visual-studio-code-bin github-cli openai-codex |

## Configs (`~/.config` unless noted)

- **Desktop:** niri, waybar (+ scripts), rofi, rofi-rbw, mako, swayosd, hypr (hyprlock, hypridle), matugen
- **Terminal:** ghostty, fish, starship, zellij, atuin, herdr, `~/.bashrc`, `~/.bash_profile`
- **TUIs:** helix (`hx` works too; F1 opens its key cheat sheet, `~/.config/helix/cheatsheet.md`; language servers in `languages.toml`), yazi, lazygit, btop, fastfetch (Shin ASCII logo), cava, eza, bat, tealdeer, wiremix, aerc, nchat, rmpc, spotify-player
- **Media / viewers:** mpd, mpv, imv, zathura
- **Apps:** Vesktop (system24 theme recolored; enabled by a chezmoi modify script);
  LibreWolf (`~/.config/librewolf/librewolf/shin`: a fixed-name profile with `user.js`,
  terminal-style `chrome/userChrome.css`, and our unsigned `extensions/shin@local` for the
  start page, theme colors and media position for waybar; add-ons come from
  `run_onchange_after_librewolf-addons.sh`);
  VS Code (Shin color theme, ported from helix's, in `~/.local/share/vscode-shin-theme`;
  `run_onchange_after_vscode-shin-theme.sh` packs and installs it; `run_onchange_after_vscode-extensions.sh` adds the extensions)
- **Partially managed** (chezmoi modify scripts set a few keys, the app owns the rest): rbw, btop.conf, Vesktop settings, VS Code settings.json (themes, font, no window buttons), Claude Code settings.json (theme, model effort)
- **Other:** metapac, mimeapps.list, user-dirs, xdg-terminals.list, `~/.gitconfig`, `~/.ssh/config` (only an `Include`, no hosts or keys), `~/.local/share/applications/spotify-player.desktop`
- **Terminal colors only (no config):** htop, gurk

## Scripts (`~/.local/bin`)

| | |
|---|---|
| `hotkeys` | hotkey cheat sheet (rofi), shown at login |
| `rofi-apps` | app launcher with Nerd Font icons |
| `powermenu` | lock / suspend / log out / reboot / shut down, plus any entries from `~/.config/powermenu.d` |
| `screenrecord` | start/stop recording the focused monitor |
| `force-quit` | kill the focused app |
| `maximize-watch` | app maximize/fullscreen -> full-width column with gaps and border |
| `rofi-pinentry` | rofi password prompt for rbw |
| `rbw-askpass` | ssh password prompts from Bitwarden for listed hosts, the terminal for the rest |
| `bluetui`, `nmtui` | themed wrappers |

## Hotkeys

Super+Shift+/ shows the main ones (the full list is in `~/.config/niri/config.kdl`). Most used: Super+Enter terminal, Super+Space launcher,
Super+E files, Super+B browser (LibreWolf), Super+V clipboard, Super+P passwords, Super+Shift+S screenshot,
Super+Alt+R record, Super+Alt+L lock, Super+Q close, Super+Shift+Q force quit.

## Day to day

```sh
chezmoi edit <file> && chezmoi apply   # or edit in place, then: chezmoi re-add
chezmoi add ~/.config/<app>            # track a new config
metapac sync                           # after editing a package group
```
