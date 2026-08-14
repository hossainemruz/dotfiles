-- Smart gaps.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
o.window({ float = false, workspace = "w[tv1]" }, { border_size = 0, rounding = 0 })
o.window({ float = false, workspace = "f[1]" }, { border_size = 0, rounding = 0 })

-- Pin workspaces to monitors.
hl.workspace_rule({ workspace = "1", monitor = "DP-3", ["default"] = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-3", ["default"] = false })
hl.workspace_rule({ workspace = "3", monitor = "DP-3", ["default"] = false })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1", ["default"] = true })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1", ["default"] = true })

hl.on("hyprland.start", function()
  hl.dispatch(hl.dsp.focus({ workspace = "1" }))
end)

-- Reusable floating-window tags.
o.window({ tag = "floating-window-large" }, {
  name = "Large floating window",
  float = true,
  center = true,
  size = { 1200, 800 },
})
o.window({ tag = "floating-window-xlarge" }, {
  name = "Very large floating window",
  float = true,
  center = true,
  size = { 1800, 1000 },
})

o.window({ title = "^(Tailscale|bluetui|Projects|profile_switcher)$" }, { tag = "+floating-window-large" })
o.window("(TUI.large)", { tag = "+floating-window-large" })
o.window("(TUI.xlarge)", { tag = "+floating-window-xlarge" })

o.window("(nz.co.mega.megasync)", {
  name = "MegaSync",
  float = true,
  pin = true,
  size = { 0, 0 },
  move = { 2200, 310 },
})

o.window("(protonvpn-app)", {
  name = "Proton VPN",
  float = true,
  pin = true,
  size = { 0, 0 },
})

o.window(
  "^(chrome-qdrant.atlassian.net__jira_software_c_projects_CRC_boards_201-Work|chrome-app.todoist.com__-Work|chrome-app.todoist.com__-Personal)$",
  { name = "Workspace 4 Apps", workspace = "4" }
)

local function special_workspace(name, command)
  hl.workspace_rule({ workspace = "special:" .. name, on_created_empty = command })
end

special_workspace("termspace", "ghostty --class=TUI.large")
special_workspace("k8s", "ghostty -e zellij -l k8s")
special_workspace("scratchpad", "ghostty -e nvim scratchpad.md")
special_workspace("yazi", "ghostty --class=TUI.xlarge -e yazi")
special_workspace("ai-usagebar", "ghostty --class=TUI.large -e ai-usagebar-tui")

special_workspace("proton-pass", "flatpak run me.proton.Pass")
o.window("(me.proton.Pass)", { tag = "+floating-window-large" })
o.window("(me.proton.Pass)", { no_screen_share = true })
o.window("(1password)", { tag = "+floating-window-large" })

special_workspace("proton-mail", "flatpak run me.proton.Mail")

special_workspace("grok", 'omarchy-launch-webapp "https://grok.com" --profile-directory=Personal')
o.window("chrome-grok.com__-Personal", { tag = "+floating-window-large" })

special_workspace(
  "grammarly",
  'omarchy-launch-webapp "https://app.grammarly.com/ddocs/369835916" --profile-directory=Personal'
)
o.window("chrome-app.grammarly.com__ddocs_369835916-Personal", { tag = "+floating-window-large" })

special_workspace("gemini", 'omarchy-launch-webapp "https://gemini.google.com/app" --profile-directory=Personal')
o.window("chrome-gemini.google.com__app-Personal", { tag = "+floating-window-large" })

special_workspace("chatgpt", 'omarchy-launch-webapp "https://chatgpt.com" --profile-directory=Personal')
o.window("chrome-chatgpt.com__-Personal", { tag = "+floating-window-large" })

special_workspace("devtoolbox", "flatpak run me.iepure.devtoolbox")
special_workspace("easyeffects", "flatpak run com.github.wwmm.easyeffects")
o.window("com.github.wwmm.easyeffects", { tag = "+floating-window-large" })

special_workspace(
  "omarchy-cheat-sheet",
  'omarchy-launch-webapp "https://acrogenesis.com/omarchy-cheat-sheet" --profile-directory=Personal'
)
o.window("chrome-acrogenesis.com__omarchy-cheat-sheet-Personal", {
  float = true,
  size = { 1600, 1100 },
})

special_workspace(
  "neovim-cheat-sheet",
  'omarchy-launch-webapp "https://hossainemruz.github.io/neovim-cheat-sheet" --profile-directory=Personal'
)
o.window("chrome-hossainemruz.github.io__neovim-cheat-sheet-Personal", {
  float = true,
  size = { 1800, 1100 },
})
