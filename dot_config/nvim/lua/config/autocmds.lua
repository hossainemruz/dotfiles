-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable only for HTML
vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.b.autoformat = false -- for formatter.nvim
    vim.b[0].autoformat = false
  end,
})

-- Configure YAML indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    -- Optional: Enable folding based on indentation for better navigation
    vim.opt_local.foldmethod = "indent"
  end,
})

--- Open markdown in Typora
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>fp", function()
      local filepath = vim.fn.expand("%:p")
      local command = vim.fn.has("mac") == 1 and { "open", "-a", "Typora", filepath } or { "typora", filepath }
      vim.fn.jobstart(command, { detach = true })
    end, { buffer = true, desc = "Open in Typora" })
  end,
})
