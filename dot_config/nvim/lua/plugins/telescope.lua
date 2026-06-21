return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fg", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
    { "<leader>fz", LazyVim.pick("live_grep"), desc = "Fuzzy Grep (Root Dir)" },
    { "<leader>fc", LazyVim.pick("grep_string", { word_match = "-w" }), desc = "Search Current Word" },
    { "<leader>fc", LazyVim.pick("grep_string"), mode = "x", desc = "Search Selection" },
  },
}
