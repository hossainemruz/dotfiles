return {
  "folke/snacks.nvim",
  keys = function()
    local terminals = {
      general = {
        count = 1,
        cmd = { "opencode", "--agent", "general" },
      },
      build = {
        count = 2,
        cmd = { "opencode", "--agent", "build" },
      },
      claude = {
        count = 3,
        cmd = { "claude" },
      },
      codex = {
        count = 4,
        cmd = { "codex" },
      },
    }

    local function project_cwd()
      return vim.uv.cwd() or vim.fn.getcwd()
    end

    local function terminal_cmd(name)
      return terminals[name].cmd
    end

    local function terminal_opts(name, cwd)
      return {
        count = terminals[name].count,
        cwd = cwd,
        win = {
          position = "right",
          width = 0.4,
        },
      }
    end

    local function get_terminal(name, cwd, create)
      return Snacks.terminal.get(
        terminal_cmd(name),
        vim.tbl_extend("force", terminal_opts(name, cwd), {
          create = create,
        })
      )
    end

    local function is_managed_terminal(terminal)
      if not terminal or not terminal:buf_valid() then
        return false
      end

      local ok, data = pcall(function()
        return vim.b[terminal.buf].snacks_terminal
      end)
      local cmd = ok and data and data.cmd or terminal.cmd

      if type(cmd) ~= "table" then
        return false
      end

      for _, terminal_config in pairs(terminals) do
        if vim.deep_equal(cmd, terminal_config.cmd) then
          return true
        end
      end

      return false
    end

    local function hide_other_managed_terminals(target)
      for _, terminal in ipairs(Snacks.terminal.list()) do
        if terminal ~= target and is_managed_terminal(terminal) and terminal:valid() then
          terminal:hide()
        end
      end
    end

    local function toggle_terminal(name)
      local cwd = project_cwd()
      local terminal = get_terminal(name, cwd, false)

      if terminal and terminal:valid() then
        terminal:hide()
        return
      end

      hide_other_managed_terminals(terminal)

      if terminal then
        terminal:show()
        terminal:focus()
        return
      end

      get_terminal(name, cwd, true)
    end

    return {
      {
        "<leader>og",
        function()
          toggle_terminal("general")
        end,
        desc = "Toggle opencode general",
      },
      {
        "<leader>ob",
        function()
          toggle_terminal("build")
        end,
        desc = "Toggle opencode build",
      },
      {
        "<leader>oc",
        function()
          toggle_terminal("claude")
        end,
        desc = "Toggle claude",
      },
      {
        "<leader>ox",
        function()
          toggle_terminal("codex")
        end,
        desc = "Toggle codex",
      },
    }
  end,
}
