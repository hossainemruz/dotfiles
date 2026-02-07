return {
  "jiaoshijie/undotree",
  opts = {}, -- This ensures setup{} is called
  keys = {
    {
      "<leader>U",
      function()
        require("undotree").toggle()
      end,
      desc = "Undo Tree",
    },
  },
}
