#!/usr/bin/env bash

set -euo pipefail

json_escape() {
  local value=${1//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

tooltip=$'UTC        Berlin     Dhaka\n---------- ---------- ----------'

current_utc_hour=$(date -u +"%H")
current_utc_hour=${current_utc_hour#0}

for h in {0..23}; do
  if [ "$h" -eq "$current_utc_hour" ]; then
    tooltip+=$'\n-------------------------------'
  fi

  utc_ref=$(printf "%02d:00" "$h")
  utc_time=$(TZ=UTC date --date="UTC ${utc_ref}" +"%I:%M %p")
  berlin_time=$(TZ=Europe/Berlin date --date="UTC ${utc_ref}" +"%I:%M %p")
  dhaka_time=$(TZ=Asia/Dhaka date --date="UTC ${utc_ref}" +"%I:%M %p")

  tooltip+=$'\n'"$(printf "%-10s %-10s %-10s" "$utc_time" "$berlin_time" "$dhaka_time")"

  if [ "$h" -eq "$current_utc_hour" ]; then
    tooltip+=$'\n-------------------------------'
  fi
done

text="󰥔"

printf '{"text":"%s","tooltip":"%s"}\n' \
  "$(json_escape "$text")" \
  "$(json_escape "$tooltip")"
