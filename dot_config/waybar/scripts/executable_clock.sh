#!/usr/bin/env bash

set -euo pipefail

# Current time in 12h format with timezone
current_time=$(date +"%d %B, %A %I:%M %p (%Z)")

# Build tooltip with ACTUAL newlines
tooltip=$'UTC        Berlin     Dhaka\n-------------------------------'

current_utc_hour=$(date -u +"%H")
current_utc_hour=${current_utc_hour#0}  # remove leading zero

for h in {0..23}; do
    if [ "$h" -eq "$current_utc_hour" ]; then
        tooltip="${tooltip}"$'\n'"-------------------------------"
    fi
    utc_ref=$(printf "%02d:00" "$h")
    utc_time=$(TZ=UTC date --date="UTC ${utc_ref}" +"%I:%M %p")
    berlin_time=$(TZ=Europe/Berlin date --date="UTC ${utc_ref}" +"%I:%M %p")
    dhaka_time=$(TZ=Asia/Dhaka date --date="UTC ${utc_ref}" +"%I:%M %p")
    row=$(printf "%-10s %-10s %-10s" "$utc_time" "$berlin_time" "$dhaka_time")
    tooltip="${tooltip}"$'\n'"${row}"
    if [ "$h" -eq "$current_utc_hour" ]; then
        tooltip="${tooltip}"$'\n'"-------------------------------"
    fi
done

# Use jq to safely encode JSON
jq -n \
    --arg text "$current_time" \
    --arg tooltip "$tooltip" \
    '{text: $text, tooltip: $tooltip}'
