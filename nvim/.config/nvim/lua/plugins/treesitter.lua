return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "cmake",
        "css",
        "dockerfile",
        "go",
        "gomod",
        "gotmpl",
        "helm",
        "proto",
        "scss",
        "terraform",
      })
    end,
  },
}
