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

-- Preview markdown in a Devcroft dialog (replaces Typora).
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>fp", function()
      -- Preview renders what is on disk; save first so the snapshot is fresh.
      if vim.bo.modified then
        vim.cmd.write()
      end
      local path = vim.api.nvim_buf_get_name(0)
      if path == "" then
        vim.notify("No file to preview.", vim.log.levels.WARN)
        return
      end
      vim.system({ "devcroft", "preview", path }, { detach = true }, function(result)
        if result.code ~= 0 then
          local output = ((result.stdout or "") .. (result.stderr or "")):gsub("%s+$", "")
          vim.schedule(function()
            vim.notify(("Preview failed (%s): %s"):format(result.code, output), vim.log.levels.ERROR)
          end)
        end
      end)
    end, { buffer = true, desc = "Devcroft: preview Markdown" })
  end,
})
