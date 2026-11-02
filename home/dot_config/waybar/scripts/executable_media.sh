#!/usr/bin/env bash
# Now playing for waybar's custom/media, from the most recently active MPRIS player
# (playerctld): play/pause icon, title · artist and [position/length]. Replaces the
# built-in mpris module, which redrew on a timer (slow play/pause icon) and showed
# [00:00] after a resume. Prints a line right away on every player event and once a
# second for the position; empty text (module hidden) when nothing is playing.
max=70 # characters; past this the artist goes, then the title is cut
sep=$'\x1f'
fmt="{{status}}$sep{{xesam:title}}$sep{{xesam:artist}}$sep{{position}}$sep{{mpris:length}}"

paused= paused_pos= # the paused track's title and position (see update)

# Microseconds -> MM:SS, or H:MM:SS from an hour on.
clock() {
  local s=$(($1 / 1000000))
  if ((s >= 3600)); then
    printf '%d:%02d:%02d' $((s / 3600)) $((s % 3600 / 60)) $((s % 60))
  else
    printf '%02d:%02d' $((s / 60)) $((s % 60))
  fi
}

markup() {
  # Quoted replacements: bash 5.2 would otherwise read & as the matched text.
  local s=${1//&/"&amp;"}
  s=${s//</"&lt;"}
  printf '%s' "${s//>/"&gt;"}"
}

update() {
  local status title artist pos len icon time text player
  IFS=$sep read -r status title artist pos len < <(playerctl -p playerctld metadata --format "$fmt" 2>/dev/null)
  if [[ $status != Playing && $status != Paused ]]; then
    echo '{"text": ""}'
    return
  fi
  [[ $status == Playing ]] && icon=󰐊 || icon=󰏤
  [[ $pos =~ ^[0-9]+$ ]] || pos=0
  [[ $len =~ ^[0-9]+$ ]] || len=0
  # Hold the position from the moment of the pause: some players (browsers) keep
  # counting while paused. Going back (a seek) still shows.
  if [[ $status == Paused ]]; then
    if [[ -n $paused_pos && $paused == "$title" ]] && ((pos > paused_pos)); then
      pos=$paused_pos
    else
      paused_pos=$pos
    fi
    paused=$title
  else
    paused= paused_pos=
  fi
  # Live streams and players that don't report a length get the position alone.
  if ((len > 0)); then
    ((pos > len)) && pos=$len
    time="[$(clock "$pos")/$(clock "$len")]"
  elif ((pos > 0)); then
    time="[$(clock "$pos")]"
  fi
  [[ -n $title ]] || title=$(basename -- "$(playerctl -p playerctld metadata xesam:url 2>/dev/null)")
  local room=$((max - ${#time} - 3))
  text=$title
  [[ -n $artist ]] && ((${#title} + 3 + ${#artist} <= room)) && text+=" · $artist"
  ((${#text} > room)) && text="${text:0:room-1}…"
  text="$icon $text${time:+ · $time}"
  # playerctld's PlayerNames lists the active player first.
  player=$(busctl --user get-property org.mpris.MediaPlayer2.playerctld /org/mpris/MediaPlayer2 \
    com.github.altdesktop.playerctld PlayerNames 2>/dev/null | awk -F'"' '{print $2}')
  player=${player#org.mpris.MediaPlayer2.}
  jq -cn --arg text "$(markup "$text")" --arg class "${status,,}" \
    --arg tooltip "$(markup "${player%%.*} (${status}):
${artist:+$artist - }$title")" '{$text, $tooltip, $class}'
}

# playerctl prints a line whenever the status or track changes; each one wakes the
# loop early, otherwise it ticks once a second.
follower=
follow() {
  [[ -n $follower ]] && kill "$follower" 2>/dev/null
  exec 3< <(exec playerctl -p playerctld --follow metadata --format '{{status}} {{xesam:title}}' 2>/dev/null)
  follower=$!
}
trap 'kill $follower 2>/dev/null' EXIT
trap exit TERM INT HUP PIPE

follow
while :; do
  update || exit
  read -r -t 1 -u 3 _ && continue
  (($? > 128)) && continue # timed out: just the once-a-second tick
  # playerctl quit (playerctld restarting?): wait a second and start it again.
  sleep 1
  follow
done
