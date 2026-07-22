return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        ["P"] = {
          "toggle_preview",
          config = {
            use_float = true,
          },
        },
      },
    },
  },
}
