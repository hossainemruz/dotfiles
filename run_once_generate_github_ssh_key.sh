#!/bin/bash

# Check if personal SSH key exists, generate if it doesn't
if [ ! -f ~/.ssh/id_ed25519_personal ]; then
  ssh-keygen -t ed25519 -C "hossainemruz@gmail.com" -f ~/.ssh/id_ed25519_personal -N ""
  echo "Generated personal SSH key."
else
  echo "Personal SSH key already exists, skipping generation."
fi

# Check if work SSH key exists, generate if it doesn't
if [ ! -f ~/.ssh/id_ed25519_work ]; then
  ssh-keygen -t ed25519 -C "emruz.hossain@qdrant.com" -f ~/.ssh/id_ed25519_work -N ""
  echo "Generated work SSH key."
else
  echo "Work SSH key already exists, skipping generation."
fi

# Start ssh-agent if not already running
if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" >/dev/null; then
  eval "$(ssh-agent -s)"
  echo "Started ssh-agent."
else
  echo "ssh-agent is already running."
fi

# Add personal SSH key to the agent if not already added
if ! ssh-add -l | grep -q "$(ssh-keygen -y -P "" -f ~/.ssh/id_ed25519_personal)"; then
  ssh-add ~/.ssh/id_ed25519_personal
  echo "Added personal SSH key to ssh-agent."
else
  echo "Personal SSH key already added to ssh-agent."
fi

# Add work SSH key to the agent if not already added
if ! ssh-add -l | grep -q "$(ssh-keygen -y -P "" -f ~/.ssh/id_ed25519_work)"; then
  ssh-add ~/.ssh/id_ed25519_work
  echo "Added work SSH key to ssh-agent."
else
  echo "Work SSH key already added to ssh-agent."
fi
