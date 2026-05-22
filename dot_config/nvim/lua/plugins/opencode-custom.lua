return {
  "folke/snacks.nvim",
  keys = function()
    local agents = {
      general = 1,
      build = 2,
    }

    local function project_cwd()
      return vim.uv.cwd() or vim.fn.getcwd()
    end

    local function terminal_cmd(agent)
      return { "opencode", "--agent", agent }
    end

    local function terminal_opts(agent, cwd)
      return {
        count = agents[agent],
        cwd = cwd,
        win = {
          position = "right",
          width = 0.4,
        },
      }
    end

    local function get_terminal(agent, cwd, create)
      return Snacks.terminal.get(
        terminal_cmd(agent),
        vim.tbl_extend("force", terminal_opts(agent, cwd), {
          create = create,
        })
      )
    end

    local function is_managed_opencode_terminal(terminal)
      if not terminal or not terminal:buf_valid() then
        return false
      end

      local ok, data = pcall(function()
        return vim.b[terminal.buf].snacks_terminal
      end)
      local cmd = ok and data and data.cmd or terminal.cmd

      return type(cmd) == "table" and cmd[1] == "opencode" and cmd[2] == "--agent" and agents[cmd[3]] ~= nil
    end

    local function hide_other_opencode_terminals(target)
      for _, terminal in ipairs(Snacks.terminal.list()) do
        if terminal ~= target and is_managed_opencode_terminal(terminal) and terminal:valid() then
          terminal:hide()
        end
      end
    end

    local function toggle_agent(agent)
      local cwd = project_cwd()
      local terminal = get_terminal(agent, cwd, false)

      if terminal and terminal:valid() then
        terminal:hide()
        return
      end

      hide_other_opencode_terminals(terminal)

      if terminal then
        terminal:show()
        terminal:focus()
        return
      end

      get_terminal(agent, cwd, true)
    end

    return {
      {
        "<leader>og",
        function()
          toggle_agent("general")
        end,
        desc = "Toggle opencode general",
      },
      {
        "<leader>ob",
        function()
          toggle_agent("build")
        end,
        desc = "Toggle opencode build",
      },
    }
  end,
}
