return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        harper_ls = {
          settings = {
            ["harper-ls"] = {
              linters = {
                SentenceCapitalization = false,
                SpellCheck = true,
              },
              diagnosticSeverity = "hint",
            },
          },
        },
      },
    },
  },
}
