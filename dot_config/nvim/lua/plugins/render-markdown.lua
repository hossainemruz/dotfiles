return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    nested = false,
    code = {
      sign = false,
      width = "block",
      right_pad = 1,
      language = true,
      language_border = " ",
      language_left = "",
      language_right = "",
      border = "thick",
      backgrounds = {},
      disable_background = false,
      inline = false,
    },
    heading = {
      sign = false,
      icons = {},
      position = "inline",
      width = "block",
      backgrounds = {},
    },
    checkbox = {
      enabled = true,
    },
  },
  ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
  config = function(_, opts)
    require("render-markdown").setup(opts)
    Snacks.toggle({
      name = "Render Markdown",
      get = require("render-markdown").get,
      set = require("render-markdown").set,
    }):map("<leader>um")
  end,
}
