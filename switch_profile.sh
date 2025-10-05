#!/bin/bash

# Function to switch $HOME/$directory symlink based on profile
# Usage: switch_directory_profile "directory" "profile"
# Example: switch_directory_profile "Downloads" "work"
switch_directory_profile() {
  local directory="$1"
  local profile="$2"
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_dir="$HOME/${directory}_backup_$timestamp"

  # Validate inputs
  if [ -z "$directory" ]; then
    echo "Error: Directory argument is required."
    return 1
  fi
  if [ -z "$profile" ]; then
    echo "Error: Profile argument is required."
    return 1
  fi
  if [[ "$profile" != "work" && "$profile" != "personal" ]]; then
    echo "Error: Invalid profile. Use 'work' or 'personal'."
    return 1
  fi

  # Define the target directory
  local target_dir="$HOME/$profile/$directory"

  # Check if the target directory exists
  if [ ! -d "$target_dir" ]; then
    echo "Error: Target directory $target_dir does not exist."
    return 1
  fi

  # Handle existing $HOME/$directory
  if [ -L "$HOME/$directory" ]; then
    # If it's a symlink, remove it
    rm "$HOME/$directory"
    echo "Removed existing symlink: $HOME/$directory"
  elif [ -d "$HOME/$directory" ]; then
    # If it's a regular directory, back it up
    echo "Warning: $HOME/$directory is a regular directory. Backing it up to $backup_dir"
    mv "$HOME/$directory" "$backup_dir"
    if [ $? -ne 0 ]; then
      echo "Error: Failed to back up $HOME/$directory to $backup_dir"
      return 1
    fi
    echo "Backed up $HOME/$directory to $backup_dir"
  elif [ -e "$HOME/$directory" ]; then
    # If it's not a directory or symlink (e.g., a file), error out
    echo "Error: $HOME/$directory exists but is not a directory or symlink. Please handle manually."
    return 1
  fi

  # Create new symlink
  ln -s "$target_dir" "$HOME/$directory"
  if [ $? -eq 0 ]; then
    echo "Successfully switched $HOME/$directory to $target_dir"
  else
    echo "Error: Failed to create symlink to $target_dir"
    return 1
  fi

  # Verify the symlink
  if [ -L "$HOME/$directory" ] && [ "$(readlink -f "$HOME/$directory")" = "$(realpath "$target_dir")" ]; then
    echo "Verification: Symlink correctly points to $target_dir"
  else
    echo "Error: Symlink verification failed."
    return 1
  fi
}

# Function to switch to personal profile
switch_to_personal_profile() {
  echo "Switching to personal profile"
  echo "🏠 Personal" >"$HOME/profile"
  # change the pointer of important directories to profile specific directories
  switch_directory_profile "Downloads" "personal"
  switch_directory_profile "Documents" "personal"
  switch_directory_profile "Pictures" "personal"
  switch_directory_profile "projects" "personal"
  # change the theme
  omarchy-theme-set tokyo-night

  echo "Swithed to personal profile"
}

# Function to switch to work profile
switch_to_work_profile() {
  echo "Switching to work profile"
  echo "💼 Work" >"$HOME/profile"
  # change the pointer of important directories to profile specific directories
  switch_directory_profile "Downloads" "work"
  switch_directory_profile "Documents" "work"
  switch_directory_profile "Pictures" "work"
  switch_directory_profile "projects" "work"
  # change the theme
  omarchy-theme-set osaka-jade

  echo "Swithed to work profile"
}

# Check if the profile indicator file exists
if [[ -f "$HOME/profile" ]]; then
  # Search for the string "Work" in the file
  if grep -q "Work" "$HOME/profile"; then
    echo "Current profile is work"
    switch_to_personal_profile
  else
    echo "Current profile is personal"
    switch_to_work_profile
  fi
else
  echo "Error: File $HOME/profile does not exist."
  switch_to_personal_profile
fi

uwsm stop
