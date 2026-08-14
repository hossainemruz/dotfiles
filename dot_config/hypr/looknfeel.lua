-- Personal layout overrides.

hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    layout = "monocle",
  },

  master = {
    mfact = 0.80,
    orientation = "left",
    new_on_top = true,
    new_status = "master",
  },
})

hl.workspace_rule({ workspace = "4", layout = "master" })
