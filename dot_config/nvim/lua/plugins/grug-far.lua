return {
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>rb",
        function()
          require("grug-far").open({
            transient = true,
            prefills = { paths = vim.fn.expand("%") },
          })
        end,
        mode = { "n", "x" },
        desc = "Replace in Buffer",
      },
      {
        "<leader>rp",
        function()
          require("grug-far").open({
            transient = true,
            prefills = { paths = LazyVim.root() },
          })
        end,
        mode = { "n", "x" },
        desc = "Replace in Project",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>r", group = "replace", mode = { "n", "x" } },
      },
    },
  },
}
