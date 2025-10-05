#!/bin/bash

# Script to create a directory hierarchy under $HOME
# Directories are created only if they don't exist (using mkdir -p)
# Hierarchy:
# $HOME
# ├── work
# │   ├── Downloads
# │   ├── Documents
# │   ├── Pictures
# │   ├── projects
# ├── personal
# │   ├── Downloads
# │   ├── Documents
# │   ├── Pictures
# │   ├── projects

# Define the relative paths for the hierarchy under $HOME
declare -a paths=(
  "work/Downloads"
  "work/Documents"
  "work/Pictures"
  "work/projects"
  "personal/Downloads"
  "personal/Documents"
  "personal/Pictures"
  "personal/projects"
)

# Create each path in the hierarchy
for path in "${paths[@]}"; do
  mkdir -p "$HOME/$path"
  echo "Ensured: $HOME/$path"
done
