#!/bin/bash

fzf_args=(
  --multi
  --preview 'echo {1}'
  --preview-label='alt-p: toggle description, alt-b/B: toggle PKGBUILD, alt-j/k: scroll, tab: multi-select, F11: maximize'
  --preview-label-pos='bottom'
  --preview-window 'down:25%:wrap'
  --bind 'alt-p:toggle-preview'
  --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
  --bind 'alt-k:preview-up,alt-j:preview-down'
  --bind 'alt-b:change-preview:yay -Gpa {1} | tail -n +5'
  --bind 'alt-B:change-preview:yay -Siia {1}'
  --color 'pointer:green,marker:green'
)

# Path to the JSON file
JSON_FILE="$HOME/.local/share/chezmoi/projects.json"

# Check if JSON file exists
if [[ ! -f "$JSON_FILE" ]]; then
  echo "Error: JSON file $JSON_FILE not found."
  exit 1
fi

# Read projects from JSON file
mapfile -t projects < <(jq -c '.[]' "$JSON_FILE")

# Loop over the projects and prepare a project names array
project_names=()
for project in "${projects[@]}"; do
  project_names+=($(echo "$project" | jq -r '.name'))
done

# Send the project names to fzf for selection
selected_project=$(printf "%s\n" "${project_names[@]}" | fzf "${fzf_args[@]}")

# Loop over the projects and open the selected project
for project in "${projects[@]}"; do
  # Extract the project informations
  name=$(echo "$project" | jq -r '.name')
  directory=$(echo "$project" | jq -r '.directory')
  ide=$(echo "$project" | jq -r '.ide')
 
  # If the project name matches selected project,open it on desired IDE
  if [[ "$name" == "$selected_project" ]]; then
    if [[ "$ide" == "nvim" ]]; then
      nohup $TERMINAL -e nvim $directory &>/dev/null &
      break
    else
      nohup $ide "$directory" &>/dev/null &
      break
    fi
  fi
done

# Give some time to open the project before we close this script 
sleep 0.01

