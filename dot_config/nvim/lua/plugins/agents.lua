return {
  "folke/snacks.nvim",
  keys = function()
    local last_terminal_name
    local last_terminal_cwd

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

    local function normalize_path(path)
      if not path or path == "" then
        return nil
      end

      return vim.fs.normalize(vim.uv.fs_realpath(path) or path)
    end

    local function project_cwd()
      return vim.fn.getcwd(0, 0)
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

    local function remember_terminal(name, cwd)
      last_terminal_name = name
      last_terminal_cwd = cwd
    end

    local function terminal_cwd(terminal)
      if not terminal or not terminal:buf_valid() then
        return nil
      end

      local ok, data = pcall(function()
        return vim.b[terminal.buf].snacks_terminal
      end)

      if ok and data and data.cwd then
        return data.cwd
      end

      return terminal.opts and terminal.opts.cwd or nil
    end

    local function terminal_matches_cwd(terminal, cwd)
      return normalize_path(terminal_cwd(terminal)) == normalize_path(cwd)
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
      remember_terminal(name, cwd)

      if terminal and terminal:win_valid() then
        terminal:hide()
        return
      end

      hide_other_managed_terminals(terminal)

      if terminal then
        terminal:show()
        terminal:focus()
        return
      end

      local created_terminal = get_terminal(name, cwd, true)
      if created_terminal then
        created_terminal:focus()
      end
    end

    local function current_buffer_relative_path()
      local path = vim.api.nvim_buf_get_name(0)

      if path == "" then
        vim.notify("Current buffer is not backed by a file", vim.log.levels.WARN)
        return nil
      end

      return vim.fn.fnamemodify(vim.fs.normalize(vim.uv.fs_realpath(path) or path), ":.")
    end

    local function current_line_reference()
      local path = current_buffer_relative_path()

      if not path then
        return nil
      end

      return string.format("@%s line %d", path, vim.api.nvim_win_get_cursor(0)[1])
    end

    local function current_file_reference()
      local path = current_buffer_relative_path()

      if not path then
        return nil
      end

      return string.format("@%s", path)
    end

    local function current_selection_reference()
      local path = current_buffer_relative_path()

      if not path then
        return nil
      end

      local start_line = vim.fn.line("v")
      local end_line = vim.fn.line(".")

      if start_line == 0 or end_line == 0 then
        vim.notify("No active selection found", vim.log.levels.WARN)
        return nil
      end

      if start_line > end_line then
        start_line, end_line = end_line, start_line
      end

      return string.format("@%s line %d - %d", path, start_line, end_line)
    end

    local function visible_managed_terminal(cwd)
      for _, terminal in ipairs(Snacks.terminal.list()) do
        if is_managed_terminal(terminal) and terminal:win_valid() and terminal_matches_cwd(terminal, cwd) then
          return terminal
        end
      end
    end

    local function current_managed_terminal(cwd)
      local current_buf = vim.api.nvim_get_current_buf()

      for _, terminal in ipairs(Snacks.terminal.list()) do
        if terminal.buf == current_buf and is_managed_terminal(terminal) and terminal_matches_cwd(terminal, cwd) then
          return terminal
        end
      end
    end

    local function remembered_managed_terminal(cwd)
      if not last_terminal_name or not last_terminal_cwd then
        return nil
      end

      local terminal = get_terminal(last_terminal_name, last_terminal_cwd, false)

      if terminal and is_managed_terminal(terminal) and terminal_matches_cwd(terminal, cwd) then
        return terminal
      end
    end

    local function any_managed_terminal(cwd)
      for _, terminal in ipairs(Snacks.terminal.list()) do
        if is_managed_terminal(terminal) and terminal_matches_cwd(terminal, cwd) then
          return terminal
        end
      end
    end

    local function reference_terminal(cwd)
      return current_managed_terminal(cwd)
        or visible_managed_terminal(cwd)
        or remembered_managed_terminal(cwd)
        or any_managed_terminal(cwd)
    end

    local function copy_reference(reference)
      vim.fn.setreg('"', reference)
      pcall(vim.fn.setreg, "+", reference)
    end

    local function focus_terminal(terminal)
      if not terminal then
        return false
      end

      hide_other_managed_terminals(terminal)

      if not terminal:win_valid() then
        terminal:show()
      end

      terminal:focus()
      vim.cmd.startinsert()
      return true
    end

    local function terminal_job_id(terminal)
      local ok, job_id = pcall(function()
        return vim.b[terminal.buf].terminal_job_id
      end)

      if ok and type(job_id) == "number" and job_id > 0 then
        return job_id
      end
    end

    local function terminal_command(terminal)
      local ok, data = pcall(function()
        return vim.b[terminal.buf].snacks_terminal
      end)

      if ok and data and data.cmd then
        return data.cmd
      end

      return terminal.cmd
    end

    local function buffer_contains(buf, needle)
      if not vim.api.nvim_buf_is_valid(buf) then
        return false
      end

      local line_count = vim.api.nvim_buf_line_count(buf)
      local start = math.max(0, line_count - 200)
      local lines = vim.api.nvim_buf_get_lines(buf, start, line_count, false)

      for _, line in ipairs(lines) do
        if line:find(needle, 1, true) then
          return true
        end
      end

      return false
    end

    local function terminal_is_ready(terminal)
      local job_id = terminal_job_id(terminal)
      if not job_id then
        return false
      end

      local cmd = terminal_command(terminal)
      if type(cmd) == "table" and vim.deep_equal(cmd, terminals.general.cmd) then
        return buffer_contains(terminal.buf, "Ask anything")
          or buffer_contains(terminal.buf, "General · DeepSeek V4 Pro OpenCode Go · max")
          or buffer_contains(terminal.buf, "ctrl+p commands")
      end

      return true
    end

    local function ensure_reference_terminal(cwd)
      local terminal = reference_terminal(cwd)

      if terminal and terminal:buf_valid() then
        return terminal
      end

      remember_terminal("general", cwd)
      hide_other_managed_terminals(nil)

      local general_terminal = get_terminal("general", cwd, true)
      if general_terminal and general_terminal:buf_valid() then
        return general_terminal
      end
    end

    local function send_reference(reference)
      if not reference then
        return
      end

      local cwd = project_cwd()
      local terminal = ensure_reference_terminal(cwd)

      if not terminal or not terminal:buf_valid() or not focus_terminal(terminal) then
        copy_reference(reference)
        vim.notify("Could not open agent terminal; copied reference instead", vim.log.levels.WARN)
        return
      end

      local attempts = 0
      local function try_send()
        attempts = attempts + 1

        if not terminal:buf_valid() then
          copy_reference(reference)
          vim.notify("Agent terminal is unavailable; copied reference instead", vim.log.levels.WARN)
          return
        end

        if not terminal_is_ready(terminal) then
          if attempts < 30 then
            vim.defer_fn(try_send, 1000)
            return
          end

          copy_reference(reference)
          vim.notify("Agent terminal did not become ready; copied reference instead", vim.log.levels.WARN)
          return
        end

        local job_id = terminal_job_id(terminal)
        if job_id then
          vim.fn.chansend(job_id, reference .. " ")
          return
        end

        copy_reference(reference)
        vim.notify("Failed to send reference; copied it instead", vim.log.levels.WARN)
      end

      vim.schedule(try_send)
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
      {
        "<leader>of",
        function()
          send_reference(current_file_reference())
        end,
        desc = "Reference current file",
      },
      {
        "<leader>ol",
        function()
          send_reference(current_line_reference())
        end,
        desc = "Reference current line",
      },
      {
        "<leader>os",
        function()
          send_reference(current_selection_reference())
        end,
        mode = "x",
        desc = "Reference selection",
      },
    }
  end,
}
