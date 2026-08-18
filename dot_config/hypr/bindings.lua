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
hl.unbind("SUPER + S")
hl.unbind("SUPER + P")

bind("ALT + B", "Bluetooth", terminal .. ' --title="bluetui" -e bluetui')
bind("SUPER + RETURN", "Terminal", terminal)
bind("SUPER + ALT + F", "File manager", "uwsm app -- nautilus --new-window")
bind("SUPER + ALT + SLASH", "Passwords", "uwsm app -- 1password")

bind("SUPER + ALT + Y", "YouTube", 'omarchy-launch-webapp "https://youtube.com/" --profile-directory=Personal')
bind("SUPER + ALT + X", "X", 'omarchy-launch-webapp "https://x.com/" --profile-directory=Personal')

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
}

for key, workspace in pairs(special_workspaces) do
	bind("SUPER + ALT + " .. key, "Toggle " .. workspace .. " workspace", hl.dsp.workspace.toggle_special(workspace))
end

-- Monocle/master layout navigation.
bind("SUPER + H", "Next layout window", hl.dsp.layout("cyclenext"))
bind("SUPER + L", "Previous layout window", hl.dsp.layout("cycleprev"))
bind("SUPER + N", "Swap with next window", hl.dsp.layout("swapnext"))

-- Cross-workspace window switcher customized for SUPER+J/K.
dofile(os.getenv("HOME") .. "/.config/hypr/window_switcher.lua")
