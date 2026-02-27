#!/usr/bin/env bash

# Declare associative array (key = folder, value = cloud)
declare -A sync_folders=(
  ["/home/emruz/CloudSync"]="Proton Drive"
)

# Build tooltip string from array
folders=""
for folder in "${!sync_folders[@]}"; do
  cloud="${sync_folders[$folder]}"
  folders+="$folder  →  $cloud\n"
done

# Set icon to indicate sync is happening
echo "{\"text\":\" 󰘿  \",\"tooltip\": \"Syncing to Proton Drive\n\nFolders:\n$folders\"}"
# Run bi-directional sync. Discard the output
rclone bisync /home/emruz/CloudSync protondrive:CloudSync --create-empty-src-dirs --compare size,modtime,checksum --slow-hash-sync-only --resilient -MvP --drive-skip-gdocs --fix-case >/dev/null 2>&1
# Update the icon to indicate sync completed
echo "{\"text\":\" 󰅠  \",\"tooltip\": \"Successfully synced some time ago\n\nFolders:\n$folders\"}"
