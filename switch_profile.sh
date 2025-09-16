#!/bin/bash

# Function to switch to personal profile
switch_to_personal_profile() {
  echo "Switching to personal profile"
  echo "🏠 Personal" >"$HOME/profile"
  echo "Swithed to personal profile"
}

# Function to switch to work profile
switch_to_work_profile() {
  echo "Switching to work profile"
  echo "💼 Work" >"$HOME/profile"
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
