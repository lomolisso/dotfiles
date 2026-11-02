#!/usr/bin/env bash
# LibreWolf add-ons (the ones Firefox had), downloaded from addons.mozilla.org into
# the shin profile; LibreWolf installs them on its next start and keeps them
# updated. uBlock Origin comes with LibreWolf. chezmoi reruns this when the list
# changes, and only fetches what's missing. A failed download fails the script, so
# the next chezmoi apply tries again.
set -euo pipefail
dir=$HOME/.config/librewolf/librewolf/shin/extensions
mkdir -p "$dir"
failed=0

# add-on id                                 addons.mozilla.org slug
while read -r id slug; do
  [[ -e $dir/$id.xpi ]] && continue
  echo "librewolf: fetching $slug"
  curl -fsSL -o "$dir/$id.xpi.part" "https://addons.mozilla.org/firefox/downloads/latest/$slug/latest.xpi" &&
    mv "$dir/$id.xpi.part" "$dir/$id.xpi" ||
    { rm -f "$dir/$id.xpi.part"; echo "librewolf: couldn't fetch $slug" >&2; failed=1; }
done <<'EOF'
{446900e4-71c2-419f-a6a7-df9c091e268b}      bitwarden-password-manager
addon@darkreader.org                        darkreader
{762f9885-5a13-4abd-9c77-433dcd38b8fd}      return-youtube-dislikes
{278b0ae0-da9d-4cc6-be81-5aa7f3202672}      re-enable-right-click
firefox-extension@steamdb.info              steam-database
{988dd4f5-e8d5-49bf-a766-ff75b0e19fe2}      csgo-trader-steam-trading
EOF
exit "$failed"
