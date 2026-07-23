local function restore_previous_workspace()
  local previous_cleanup = rawget(_G, "WorkspaceReloadCleanup")
  if type(previous_cleanup) == "function" then
    pcall(previous_cleanup, { reload = true })
  end
  _G.WorkspaceReloadCleanup = nil

  local previous_tabline = rawget(_G, "WorkspaceTablineState")
  if previous_tabline and previous_tabline.active then
    vim.o.tabline = previous_tabline.tabline
    vim.o.showtabline = previous_tabline.showtabline
    for tabpage in pairs(previous_tabline.tabs or {}) do
      if vim.api.nvim_tabpage_is_valid(tabpage) then
        pcall(vim.api.nvim_tabpage_del_var, tabpage, "workspace_role")
      end
    end
  end
  _G.WorkspaceTabline = nil
  _G.WorkspaceTablineState = nil
end

return {
  {
    "folke/snacks.nvim",
    keys = function()
      restore_previous_workspace()
      package.loaded["config.workspace.tabs"] = nil
      package.loaded["config.workspace.agents"] = nil

      local tabs = require("config.workspace.tabs")
      local agents = require("config.workspace.agents")
      agents.setup(tabs)

      local function cleanup(opts)
        agents.cleanup(opts)
        tabs.cleanup(opts)
      end

      _G.WorkspaceReloadCleanup = cleanup
      tabs.setup({
        agent_manager = agents,
        cleanup = cleanup,
      })

      return vim.list_extend(tabs.keys(), agents.keys())
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "agent", icon = "🤖", mode = { "n", "x" } },
      },
    },
  },
}
