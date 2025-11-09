-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.require'nvim-treesitter.foldexpr'()"
vim.opt.foldlevel = 99 -- Start unfolded; adjust as needed

-- Filetype detection for templated YAML files
vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
  -- Apply the extension only for the files that matches this pattern
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})

-- Filetype detection for templated HTML
vim.filetype.add({
  extension = {
    gohtml = "gohtml", -- For files like example.gohtml
  },
  -- Apply the extension on files that match this pattern
  pattern = {
    [".*/layouts/.*%.html"] = "gohtml",
  },
})

-- Associate the custom filetype with the gotmpl parser
vim.treesitter.language.register("gotmpl", "gohtml")
