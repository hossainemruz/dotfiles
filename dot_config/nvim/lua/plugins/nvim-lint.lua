return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        -- LazyVim's markdown extra uses markdownlint-cli2, not markdownlint
        ["markdownlint-cli2"] = {
          args = {
            "--config",
            vim.fn.stdpath("config") .. "/.markdownlint-cli2.jsonc",
            "-",
          },
        },
      },
    },
  },
}
