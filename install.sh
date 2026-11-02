#!/usr/bin/env bash
# Takes a clean Arch install to the full rice. Run it as your normal user, after
# the first boot, with network:
#   curl -fsSL https://raw.githubusercontent.com/lomolisso/dotfiles/main/install.sh | bash
# It asks for the sudo password and your Bitwarden email once, then runs unattended.
# Safe to rerun. Machine-specific setup (GPU driver, monitor, dual boot) isn't here:
# see machines/.
set -euo pipefail

REPO=lomolisso/dotfiles
DOTFILES=$HOME/dotfiles

say() { printf '\n\033[1;31m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
die() { printf '\nSTOP: %s\n' "$*" >&2; exit 1; }
warnings=()
warn() { warnings+=("$*"); printf 'WARNING: %s\n' "$*" >&2; }

[[ $EUID -ne 0 ]] || die "run this as your normal user, not root (it uses sudo when needed)"
[[ -f /etc/arch-release ]] || die "this is for Arch Linux"
command -v sudo >/dev/null || die "sudo isn't installed"
curl -fsS -m 15 -o /dev/null https://archlinux.org || die "no network"

# Everything interactive happens here. Prompts read the terminal, since stdin is
# the script itself under `curl | bash`.
say "Setup"
sudo -v </dev/tty
first_run=false
[[ -f $HOME/.config/chezmoi/chezmoi.toml ]] || first_run=true
email=
if $first_run; then
  read -r -p "Bitwarden account email (empty to skip): " email </dev/tty
fi

# Keep sudo alive through long AUR builds.
while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done 2>/dev/null &
keepalive=$!
trap 'kill "$keepalive" 2>/dev/null || true' EXIT

# rustup goes first: AUR builds below then use it instead of pulling in `rust`,
# which conflicts with it.
say "Updating the system and installing the basics"
sudo pacman -Syu --needed --noconfirm base-devel git chezmoi jq rustup
rustup default stable
rustup component add rust-analyzer

say "Getting the dotfiles"
if [[ ! -d $DOTFILES/.git ]]; then
  git clone "https://github.com/$REPO.git" "$DOTFILES"
  git -C "$DOTFILES" remote set-url --push origin "git@github.com:$REPO.git"
fi

# chezmoi's run scripts need the packages, so they wait until those are in. --force
# replaces the stock ~/.bashrc and friends, on the first run only: on a rerun chezmoi
# asks before overwriting anything you changed.
say "Deploying the configs"
if $first_run; then
  # --promptString matches the question's text in home/.chezmoi.toml.tmpl.
  chezmoi init --source "$DOTFILES" --promptString "Bitwarden account email (empty to skip)=$email"
  chezmoi apply --force --exclude scripts
else
  chezmoi apply --exclude scripts </dev/tty
fi

say "Installing the packages"
if ! command -v paru >/dev/null; then
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/paru.git "$tmp/paru"
  (cd "$tmp/paru" && makepkg -sir --noconfirm)
  rm -rf "$tmp"
fi
command -v metapac >/dev/null || paru -S --needed --noconfirm metapac
metapac sync --no-confirm   # also enables services, through the groups' hooks

say "System settings"
sudo install -Dm644 "$DOTFILES/system/greetd/config.toml" /etc/greetd/config.toml
sudo install -Dm644 "$DOTFILES/system/zram-generator.conf" /etc/systemd/zram-generator.conf
# Firewall on from the next boot: blocks incoming, allows outgoing (ufw's defaults).
sudo sed -i 's/^ENABLED=.*/ENABLED=yes/' /etc/ufw/ufw.conf
sudo usermod -aG seat "$USER"
sudo systemctl enable fstrim.timer systemd-timesyncd.service

say "Generating colors"
matugen image "$HOME/Pictures/wallpapers/shin.jpg" --source-color-index 0 -t scheme-fidelity
niri validate

# Downloads that shouldn't throw away everything above if a site is having a moment:
# rerunning this script picks up whatever failed.
say "Editor extensions, browser add-ons, Claude Code and herdr"
chezmoi apply --include scripts </dev/null ||
  warn "some chezmoi scripts failed (VS Code extensions, LibreWolf add-ons, metals)"
command -v claude >/dev/null || [[ -x $HOME/.local/bin/claude ]] ||
  curl -fsSL https://claude.ai/install.sh | bash || warn "Claude Code didn't install"
command -v herdr >/dev/null || [[ -x $HOME/.local/bin/herdr ]] ||
  curl -fsSL https://herdr.dev/install.sh | sh || warn "herdr didn't install"
# herdr wants each agent's config folder to exist, which they only create on first run.
for agent in claude codex; do
  mkdir -p "$HOME/.$agent"
  "$HOME/.local/bin/herdr" integration install "$agent" || warn "herdr's $agent integration didn't install"
done
chezmoi apply --force "$HOME/.claude/settings.json"   # herdr just rewrote it, unformatted

# Which GPU driver to use is per machine, but a black screen is a bad way to find out.
for device in /sys/bus/pci/devices/*; do
  if [[ $(<"$device/vendor") == 0x10de && $(<"$device/class") == 0x03* ]] &&
    ! pacman -Qsq '^nvidia(-open)?(-dkms|-lts)?$' &>/dev/null; then
    warn "NVIDIA GPU with no NVIDIA driver installed; niri may not start well until one is (machines/ or nvidia-open)"
  fi
done

say "Done"
cat <<MSG
Reboot, and the login screen starts niri.

After the first login:
  Bitwarden    rbw login && rbw sync  (Super+P picks passwords)
  Spotify      put an app ID in ~/.config/spotify-player/client_id, then
               spotify_player authenticate
  Apps         log in to Vesktop and LibreWolf (LibreWolf's Bitwarden add-on too)

Optional:
  This computer's hardware and dual boot   $DOTFILES/machines/<computer>/install.sh
  Private settings (needs an SSH key)      git clone git@github.com:lomolisso/dotfiles-private.git ~/dotfiles-private
                                           ~/dotfiles-private/install.sh
MSG
if ((${#warnings[@]})); then
  printf '\nThese need another look (rerunning this script retries them):\n'
  printf '  - %s\n' "${warnings[@]}"
fi
