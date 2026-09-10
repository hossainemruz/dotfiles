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
bind("ALT + grave", "Quake Terminal", hl.dsp.workspace.toggle_special("termspace"))

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
	U = "ai-usagebar",
	V = "neovim-cheat-sheet",
}

for key, workspace in pairs(special_workspaces) do
	bind("SUPER + ALT + " .. key, "Toggle " .. workspace .. " workspace", hl.dsp.workspace.toggle_special(workspace))
end

-- Layout-aware column navigation / window swap.
-- Scrolling workspaces scroll the viewport, master workspaces swap along the
-- stack, and anything else (dwindle, custom layouts) falls back to a
-- directional swap that works everywhere.
local function layout_aware_step(next)
	return function()
		local workspace = hl.get_active_workspace and hl.get_active_workspace()
		local layout = workspace and workspace.tiled_layout
		if layout == "scrolling" then
			hl.dispatch(hl.dsp.layout(next and "move +col" or "move -col"))
		elseif layout == "master" then
			hl.dispatch(hl.dsp.layout(next and "swapnext" or "swapprev"))
		else
			hl.dispatch(hl.dsp.window.swap({ direction = next and "r" or "l" }))
		end
	end
end

hl.unbind("SUPER + N") -- Freed; swap lives on comma/period now.

-- Monocle/master layout navigation.
bind("SUPER + H", "Next layout window", hl.dsp.layout("cyclenext"))
bind("SUPER + L", "Previous layout window", hl.dsp.layout("cycleprev"))
-- Scrolling layout navigation, master layout swap.
bind("SUPER + period", "Next column / swap next", layout_aware_step(true))
bind("SUPER + comma", "Previous column / swap previous", layout_aware_step(false))

-- Window switcher
-- Cross-workspace window switcher customized for SUPER+J.
dofile(os.getenv("HOME") .. "/.config/hypr/window_switcher.lua")
