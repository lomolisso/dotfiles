#!/usr/bin/env bash
# VPN indicator for waybar's custom/vpn: an icon while any VPN tunnel (tun*,
# wg*, ppp*) has an address, nothing otherwise (which hides the module).
# A VPN script can refresh it right away on connect/disconnect (signal 9).
read -r dev addr < <(ip -o -4 addr show 2>/dev/null |
  awk '$2 ~ /^(tun|wg|ppp)/ { sub(/\/.*/, "", $4); print $2, $4; exit }') || true
if [[ -z ${dev:-} ]]; then
  echo '{"text": ""}'
  exit
fi
printf '{"text": "\U000f0582", "tooltip": "VPN · %s (%s)", "class": "connected"}\n' "$addr" "$dev"
