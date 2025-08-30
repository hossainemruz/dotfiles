return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.nvim",
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    config = function()
      require("render-markdown").setup({
        render_modes = true,
      })
    end,
    completions = { lsp = { enabled = true } },
  },
}
