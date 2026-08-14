o.exec_on_start("vicinae server")

hl.unbind("CTRL + SPACE")
o.bind("CTRL + SPACE", "Vicinae", "vicinae toggle")

hl.layer_rule({
  name = "vicinae-blur",
  match = { namespace = "vicinae" },
  blur = true,
  ignore_alpha = 0,
})

hl.layer_rule({
  name = "vicinae-no-animation",
  match = { namespace = "vicinae" },
  no_anim = true,
})
