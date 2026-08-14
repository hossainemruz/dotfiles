-- Personal keybinding overrides.

local function bind(keys, description, dispatcher)
  hl.unbind(keys)
  o.bind(keys, description, dispatcher)
end

local terminal = "uwsm app -- $TERMINAL"
local browser = "omarchy-launch-browser"

-- Disable Omarchy's display-scale bindings.
hl.unbind("SUPER + SLASH")
hl.unbind("SUPER + ALT + SLASH")

bind(
  "SUPER + ALT + RETURN",
  "Tmux",
  'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)" tmux new'
)
bind("SUPER + RETURN", "Terminal", terminal)
bind("SUPER + SHIFT + RETURN", "Browser", "omarchy-launch-browser")
bind("SUPER + SHIFT + F", "File manager", "uwsm app -- nautilus --new-window")
bind("SUPER + SHIFT + B", "Browser", browser)
bind("SUPER + SHIFT + ALT + B", "Browser (private)", browser .. " --private")
bind("SUPER + SHIFT + N", "Editor", "omarchy-launch-editor")
bind("SUPER + SHIFT + M", "Activity", "omarchy-launch-tui btop")
bind("SUPER + SHIFT + D", "Docker", "omarchy-launch-tui lazydocker")
bind("SUPER + SHIFT + O", "Obsidian", 'omarchy-launch-or-focus obsidian "uwsm-app -- obsidian"')
bind("SUPER + SHIFT + SLASH", "Passwords", "uwsm app -- 1password")
bind("ALT + B", "Bluetooth", terminal .. ' --title="bluetui" -e bluetui')

bind("SUPER + SHIFT + Y", "YouTube", 'omarchy-launch-webapp "https://youtube.com/" --profile-directory=Personal')
bind("SUPER + SHIFT + X", "X", 'omarchy-launch-webapp "https://x.com/" --profile-directory=Personal')
bind("SUPER + SHIFT + S", "Slack", "omarchy-launch-or-focus slack")
bind("SUPER + SHIFT + E", "Email", 'omarchy-launch-webapp "https://mail.google.com" --profile-directory=Work')
bind("SUPER + SHIFT + C", "Calendar", 'omarchy-launch-webapp "https://calendar.google.com" --profile-directory=Work')

local special_workspaces = {
  C = "chatgpt",
  A = "easyeffects",
  D = "devtoolbox",
  G = "grok",
  H = "grammarly",
  J = "gemini",
  K = "k8s",
  M = "proton-mail",
  N = "scratchpad",
  O = "omarchy-cheat-sheet",
  P = "proton-pass",
  T = "termspace",
  U = "ai-usagebar",
  V = "neovim-cheat-sheet",
  Y = "yazi",
}

for key, workspace in pairs(special_workspaces) do
  bind(
    "SUPER + ALT + " .. key,
    "Toggle " .. workspace .. " workspace",
    hl.dsp.workspace.toggle_special(workspace)
  )
end

-- Monocle/master layout navigation.
bind("SUPER + H", "Next layout window", hl.dsp.layout("cyclenext"))
bind("SUPER + L", "Previous layout window", hl.dsp.layout("cycleprev"))
bind("SUPER + N", "Swap with next window", hl.dsp.layout("swapnext"))
