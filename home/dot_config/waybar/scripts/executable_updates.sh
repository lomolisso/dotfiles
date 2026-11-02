#!/usr/bin/env bash
# Pending repo + AUR updates for waybar's custom/updatespacman. Prints an empty
# text when up to date, which hides the module.
repo=$(checkupdates 2>/dev/null | wc -l)
aur=$(paru -Qua 2>/dev/null | wc -l)
n=$((repo + aur))
if ((n > 0)); then
  printf '{"text":"%d󰏖","tooltip":"%d repo + %d AUR updates. Click to update.","class":"has-updates"}\n' "$n" "$repo" "$aur"
else
  echo '{"text":"","class":"updated"}'
fi
