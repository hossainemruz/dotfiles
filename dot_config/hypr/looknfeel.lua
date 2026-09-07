-- Personal layout overrides.

hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		layout = "scrolling",
	},

	master = {
		mfact = 0.80,
		orientation = "left",
		new_on_top = true,
		new_status = "master",
	},
	scrolling = {
		fullscreen_on_one_column = true,
		column_width = 0.98,
		focus_fit_method = 1,
		follow_focus = true,
	},
})

hl.workspace_rule({ workspace = "4", layout = "master" })
