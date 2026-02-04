#!/usr/bin/env bash

# Fail fast on errors
set -euo pipefail

# Wait for Hyprland to settle
sleep 2

# Browser (workspace 1) — assuming omarchy-launch-browser handles its own workspace
hyprctl dispatch exec "[workspace 1 silent] omarchy-launch-browser"
hyprctl dispatch exec "[workspace 1 silent] megasync"

# Terminal (workspace 2)
hyprctl dispatch exec "[workspace 2 silent] ghostty"

# Wait for second monitor (HDMI-A-1), max 30 seconds
timeout=30
counter=0
while ! hyprctl monitors | grep -q "HDMI-A-1"; do
    sleep 1
    counter=$((counter + 1))
    if [ "$counter" -ge "$timeout" ]; then
        echo "Second monitor not detected after $timeout seconds; continuing anyway."
        break
    fi
done

# Now launch profile-specific apps once
if grep -q "Work" "$HOME/profile"; then
    # Work profile
    hyprctl dispatch exec "slack"
    sleep 1
    hyprctl dispatch exec 'omarchy-launch-webapp "https://qdrant.atlassian.net/jira/software/c/projects/CRC/boards/201" --profile-directory=Work'
    sleep 1
    hyprctl dispatch exec 'omarchy-launch-webapp "https://app.todoist.com" --profile-directory=Work'
else
    # Personal profile
    hyprctl dispatch exec 'omarchy-launch-webapp "https://app.todoist.com" --profile-directory=Personal'
fi

