return {
  "folke/snacks.nvim",
  opts = {
    scroll = {
      enabled = false, -- Disable scrolling animations
    },
    lazygit = {
      enabled = true,
      configure = true,
      config = {
        os = { editPreset = "nvim" },
      },
      win = {
        width = 0.9,
        height = 0.9,
        relative = "editor",
        border = "rounded",
      },
    },
    terminal = {
      win = {
        width = 1.0,
        height = 0.8,
      },
    },
    input = {}, -- Enhances opencode `ask()`
    picker = { -- Enhances opencode `select()`
      actions = {
        opencode_send = function(...)
          return require("opencode").snacks_picker_send(...)
        end,
      },
      win = {
        input = {
          keys = {
            ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
          },
        },
      },
    },
  },
}
