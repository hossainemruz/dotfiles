#!/bin/bash

# Function to move a window to a workspace based on a matching pattern
move_to_workspace() {
    local pattern="$1"  # Pattern to match (e.g., window class or title)
    local workspace="$2" # Target workspace
    local match_type="$3" # Match by "class" or "title"

    echo "pattern: $pattern"
    echo "workspace: $workspace"
    echo "match_type: $match_type"

    # Get all clients (windows) and filter by pattern
    while IFS= read -r line; do
        echo "line: $line"
        # Extract client address
        if [[ $line =~ (0x[0-9a-f]+) ]]; then
            address="${BASH_REMATCH[1]}"
            # Move the window to the specified workspace
            hyprctl dispatch movetoworkspace "$workspace,address:$address"
            echo "Moved window (address: $address) to workspace $workspace"
        fi
    done < <(hyprctl clients -j | jq -r ".[] | select(.$match_type | test(\"$pattern\"; \"i\")) | .address")
}

sleep 5

# Define your applications and target workspaces
# Format: move_to_workspace "pattern" "workspace" "match_type"
move_to_workspace "chrome-app.todoist.com__-Work" "5" "class"

# Add more applications as needed
# Example for title-based matching:
# move_to_workspace "Spotify" "5" "title"
