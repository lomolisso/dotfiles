#!/usr/bin/env bash
# Weather for waybar's custom/weather: wttrbar, or Open-Meteo while wttr.in is
# down (same icon + temperature on the bar). wttrbar keeps retrying for minutes
# when the site is down, so it gets a time limit. If both fail, printing nothing
# and exiting non-zero hides the module until the next try.
if out=$(timeout 20 wttrbar --nerd 2>/dev/null) &&
  jq -e '.text and ((.tooltip // "") | contains("cannot access") | not)' <<<"$out" >/dev/null 2>&1; then
  printf '%s\n' "$out"
  exit
fi

# Open-Meteo needs coordinates: the place wttr.in last detected from the IP, kept
# in wttrbar's cache until a reboot, or else Champaign.
cache=/tmp/wttrbar--wttr.in.json
IFS=$'\t' read -r lat lon place < <(jq -r '.nearest_area[0] |
  [.latitude, .longitude, "\(.areaName[0].value), \(.region[0].value)"] | @tsv' "$cache" 2>/dev/null)
[[ -n ${lat:-} ]] || { lat=40.116 lon=-88.243 place="Champaign, Illinois"; }

url="https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&timezone=auto&forecast_days=3"
url+="&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m"
url+="&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset"
data=$(curl -fsS -m 10 "$url" 2>/dev/null) && jq -e .current <<<"$data" >/dev/null 2>&1 || exit 1

# Sets icon and desc from a WMO weather code; wttrbar's --nerd icons.
wmo() {
  case $1 in
    0) icon=$'\U000f0599' desc="Clear" ;;
    1) icon=$'\U000f0599' desc="Mostly clear" ;;
    2) icon=$'\U000f0595' desc="Partly cloudy" ;;
    3) icon=$'\U000f0590' desc="Overcast" ;;
    45 | 48) icon=$'\U000f0591' desc="Fog" ;;
    51 | 53 | 55 | 56 | 57) icon=$'\U000f0597' desc="Drizzle" ;;
    61 | 63 | 66 | 80 | 81) icon=$'\U000f0597' desc="Rain" ;;
    65 | 67 | 82) icon=$'\U000f0596' desc="Heavy rain" ;;
    71 | 73 | 75 | 77 | 85 | 86) icon=$'\U000f0598' desc="Snow" ;;
    95 | 96 | 99) icon=$'\U000f0593' desc="Thunderstorm" ;;
    *) icon=$'\U000f0590' desc="Unknown" ;;
  esac
}

IFS=$'\t' read -r temp feels wind humidity code < <(jq -r '.current |
  [(.temperature_2m | round), (.apparent_temperature | round), (.wind_speed_10m | round),
   .relative_humidity_2m, .weather_code] | @tsv' <<<"$data")
wmo "$code"
text="$icon $temp"
tooltip="<b>$desc</b> $temp°
Feels Like: $feels°
Wind: $wind km/h
Humidity: $humidity%
Location: $place
Source: Open-Meteo (wttr.in is down)"

while IFS=$'\t' read -r day code high low rain sunrise sunset; do
  wmo "$code"
  tooltip+="

<b>$day</b>
$icon  $desc, $high° / $low°, rain $rain%
Sun: $sunrise to $sunset"
done < <(jq -r '.daily | range(0; .time | length) as $i |
  [.time[$i], .weather_code[$i], (.temperature_2m_max[$i] | round), (.temperature_2m_min[$i] | round),
   .precipitation_probability_max[$i], .sunrise[$i][11:], .sunset[$i][11:]] | @tsv' <<<"$data")

jq -cn --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
