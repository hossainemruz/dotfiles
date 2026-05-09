return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  opts = {
    enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
    view = {
      default = {
        winbar_info = true, -- See ':h diffview-config-view.x.winbar_info'
      },
    },
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
    {
      "<leader>gv",
      function()
        if next(require("diffview.lib").views) == nil then
          vim.cmd("DiffviewOpen")
        else
          vim.cmd("DiffviewClose")
        end
      end,
      desc = "Toggle Diffview",
    },
  },
}
