-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.require'nvim-treesitter.foldexpr'()"
vim.opt.foldlevel = 99 -- Start unfolded; adjust as needed
