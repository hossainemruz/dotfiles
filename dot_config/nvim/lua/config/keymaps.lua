-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Move current line down (Alt+j)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true })
-- Move current line up (Alth+k)
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true })
-- Move selected lines down in visual mode (Alt+j)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
-- Move selected lines up in visual mode (Alt + k)
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
