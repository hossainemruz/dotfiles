return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  keys = {
    { "<space>fB", ":Telescope file_browser<CR>", desc = "File Browser (root)" },
    { "<space>fC", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", desc = "File browser (cwd)" },
  },
}
