-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Disable LazyVim's terminal shortcut (Ctrl-/ is commonly reported as Ctrl-_).
for _, lhs in ipairs({ "<C-/>", "<C-_>" }) do
  vim.keymap.del({ "n", "t" }, lhs)
end

vim.keymap.set("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy absolute file path" })

-- Devcroft code references ---------------------------------------------------
-- The loopback client lives in lua/config/devcroft.lua; autocmds bind
-- <leader>fp for markdown previews there.
local devcroft = require("config.devcroft")

-- Reference the current line to the Devcroft Agent.
vim.keymap.set("n", "<leader>al", function()
  local line = vim.fn.line(".")
  devcroft.send_reference(line, line)
end, { desc = "Devcroft: reference current line" })

-- Reference a visual selection to the Devcroft Agent.
-- Inside an x-mode map the '< '> marks are not finalized yet; the 'v anchor
-- mark plus the current cursor line are the live selection bounds.
vim.keymap.set("x", "<leader>as", function()
  local anchor_line = vim.fn.getpos("v")[2]
  local cursor_line = vim.fn.line(".")
  devcroft.send_reference(math.min(anchor_line, cursor_line), math.max(anchor_line, cursor_line))
end, { desc = "Devcroft: reference visual selection" })
