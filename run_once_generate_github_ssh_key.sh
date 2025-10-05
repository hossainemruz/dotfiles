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

# Function to generate GPG key non-interactively
generate_gpg_key() {
  local email=$1
  local name=$2
  local key_file=~/.gnupg/${email}_gpg_key
  local key_id_file=~/.gnupg/${email}_gpg_key_id

  # Check if GPG key already exists for this email
  if [ -f "$key_id_file" ] && gpg --list-secret-keys "$email" >/dev/null 2>&1; then
    echo "GPG key for $email already exists, skipping generation."
    return
  fi

  # Generate GPG key
  cat >gpg_key_gen <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $name
Name-Email: $email
Expire-Date: 0
%commit
EOF

  gpg --batch --generate-key gpg_key_gen
  rm gpg_key_gen
  echo "Generated GPG key for $email."

  # Store the key ID for future reference
  local key_id=$(gpg --list-secret-keys --keyid-format LONG "$email" | grep '^sec' | awk '{print $2}' | cut -d'/' -f2)
  echo "$key_id" >"$key_id_file"
}

# Generate GPG key for personal profile
generate_gpg_key "hossainemruz@gmail.com" "Hossain Emruz"

# Generate GPG key for work profile
generate_gpg_key "emruz.hossain@qdrant.com" "Emruz Hossain (Work)"

# Instructions for adding GPG public keys to GitHub
echo "To add your GPG keys to GitHub:"
echo "1. Run 'gpg --armor --export hossainemruz@gmail.com' and copy the output."
echo "2. Add it to GitHub: Settings > SSH and GPG keys > New GPG key."
echo "3. Repeat for 'gpg --armor --export emruz.hossain@qdrant.com'."
