return {
  {
    "folke/snacks.nvim",
    keys = function()
      local last_terminal_name
      local last_terminal_cwd
      local close_agent_panel

      local terminals = {
        opencode = {
          count = 1,
          cmd = { "env", "OPENCODE_EXPERIMENTAL_LSP_TOOL=true", "OPENCODE_ENABLE_EXA=1", "opencode" },
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
      local diff_terminal = {
        count = 1,
        cmd = { "hunk", "diff", "--watch" },
      }
      local agent_panel = {
        closing = false,
        transitioning = false,
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

      local function current_tabpage()
        return vim.api.nvim_get_current_tabpage()
      end

      local function valid_tabpage(tabpage)
        return tabpage and vim.api.nvim_tabpage_is_valid(tabpage)
      end

      local panel_close_scheduled = false
      local function schedule_panel_close(terminal)
        if
          agent_panel.closing
          or agent_panel.transitioning
          or (terminal ~= agent_panel.agent_terminal and terminal ~= agent_panel.diff_terminal)
          or panel_close_scheduled
        then
          return
        end

        panel_close_scheduled = true
        vim.schedule(function()
          panel_close_scheduled = false
          if
            not agent_panel.closing
            and not agent_panel.transitioning
            and (terminal == agent_panel.agent_terminal or terminal == agent_panel.diff_terminal)
          then
            close_agent_panel()
          end
        end)
      end

      local function terminal_opts(name, cwd)
        return {
          count = terminals[name].count,
          cwd = cwd,
          win = {
            position = "current",
            on_close = schedule_panel_close,
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

      local function managed_terminal_name(terminal)
        if not terminal or not terminal:buf_valid() then
          return nil
        end

        local ok, data = pcall(function()
          return vim.b[terminal.buf].snacks_terminal
        end)
        local cmd = ok and data and data.cmd or terminal.cmd

        if type(cmd) ~= "table" then
          return nil
        end

        for name, terminal_config in pairs(terminals) do
          if vim.deep_equal(cmd, terminal_config.cmd) then
            return name
          end
        end

        return nil
      end

      local function is_managed_terminal(terminal)
        return managed_terminal_name(terminal) ~= nil
      end

      local function agent_panel_is_open()
        return valid_tabpage(agent_panel.tabpage)
      end

      local function sync_agent_panel_tabline()
        if agent_panel_is_open() then
          vim.o.showtabline = 0
        elseif agent_panel.showtabline ~= nil then
          vim.o.showtabline = agent_panel.showtabline
        end
      end

      local agent_panel_tabline = vim.api.nvim_create_augroup("agent_panel_tabline", { clear = true })
      vim.api.nvim_create_autocmd("TabEnter", {
        group = agent_panel_tabline,
        callback = sync_agent_panel_tabline,
      })

      local function hide_other_managed_terminals(target)
        for _, terminal in ipairs(Snacks.terminal.list()) do
          if terminal ~= target and is_managed_terminal(terminal) and terminal:valid() then
            terminal:hide()
          end
        end
      end

      close_agent_panel = function()
        if agent_panel.closing or not agent_panel.tabpage then
          return
        end

        agent_panel.closing = true
        local panel_tabpage = agent_panel.tabpage
        local return_tabpage = agent_panel.return_tabpage
        local return_win = agent_panel.return_win
        local panel_was_current = valid_tabpage(panel_tabpage) and current_tabpage() == panel_tabpage
        local terminal = agent_panel.agent_terminal
        local watcher = agent_panel.diff_terminal

        if terminal and terminal:win_valid() then
          terminal:hide()
        end

        -- The agent session survives panel toggles, but the diff watcher should
        -- only run while the panel is visible.
        if watcher and watcher:buf_valid() then
          watcher:close()
        end

        if valid_tabpage(panel_tabpage) then
          local tab_number = vim.api.nvim_tabpage_get_number(panel_tabpage)
          pcall(vim.cmd, "silent! tabclose " .. tab_number)
        end

        if agent_panel.showtabline ~= nil then
          vim.o.showtabline = agent_panel.showtabline
        end

        agent_panel.tabpage = nil
        agent_panel.return_tabpage = nil
        agent_panel.return_win = nil
        agent_panel.agent_terminal = nil
        agent_panel.diff_terminal = nil
        agent_panel.showtabline = nil
        agent_panel.closing = false

        if panel_was_current and valid_tabpage(return_tabpage) then
          pcall(vim.api.nvim_set_current_tabpage, return_tabpage)
          if
            return_win
            and vim.api.nvim_win_is_valid(return_win)
            and vim.api.nvim_win_get_tabpage(return_win) == return_tabpage
          then
            pcall(vim.api.nvim_set_current_win, return_win)
          end
        end
      end

      local function open_agent_panel(name, cwd, terminal)
        if agent_panel_is_open() then
          close_agent_panel()
        end

        hide_other_managed_terminals(nil)

        local return_tabpage = current_tabpage()
        local return_win = vim.api.nvim_get_current_win()

        -- A temporary tab keeps the editor layout intact for restoration.
        agent_panel.showtabline = vim.o.showtabline
        vim.cmd.tabnew()
        local placeholder_buf = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_get_name(placeholder_buf) == "" and vim.bo[placeholder_buf].buftype == "" then
          vim.bo[placeholder_buf].bufhidden = "wipe"
        end
        agent_panel.tabpage = current_tabpage()
        agent_panel.return_tabpage = return_tabpage
        agent_panel.return_win = return_win
        agent_panel.transitioning = true
        sync_agent_panel_tabline()

        terminal = terminal or get_terminal(name, cwd, true)
        agent_panel.agent_terminal = terminal
        if not terminal then
          agent_panel.transitioning = false
          close_agent_panel()
          vim.notify("Could not open agent terminal", vim.log.levels.ERROR)
          return nil
        end

        if not terminal:win_valid() then
          terminal:show()
        end

        local watcher = Snacks.terminal.get(diff_terminal.cmd, {
          count = diff_terminal.count,
          cwd = cwd,
          interactive = false,
          auto_insert = true,
          win = {
            position = "right",
            relative = "win",
            win = terminal.win,
            width = 0.6,
            stack = false,
            enter = false,
            wo = {
              winbar = diff_terminal.count .. ": Hunk",
            },
            on_close = schedule_panel_close,
          },
        })
        agent_panel.diff_terminal = watcher
        agent_panel.transitioning = false

        terminal:focus()
        vim.cmd.startinsert()
        return terminal
      end

      local function toggle_terminal(name)
        local cwd = project_cwd()
        local terminal = get_terminal(name, cwd, false)
        remember_terminal(name, cwd)

        if agent_panel_is_open() and terminal and agent_panel.agent_terminal == terminal then
          close_agent_panel()
          return
        end

        open_agent_panel(name, cwd, terminal)
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
        local name = managed_terminal_name(terminal)
        local cwd = terminal_cwd(terminal)
        if not name or not cwd then
          return false
        end

        if agent_panel_is_open() and agent_panel.agent_terminal == terminal and terminal:win_valid() then
          if current_tabpage() ~= agent_panel.tabpage then
            vim.api.nvim_set_current_tabpage(agent_panel.tabpage)
          end
        else
          terminal = open_agent_panel(name, cwd, terminal)
          if not terminal then
            return false
          end
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
        if type(cmd) == "table" and vim.deep_equal(cmd, terminals.opencode.cmd) then
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

        remember_terminal("opencode", cwd)
        local opencode_terminal = open_agent_panel("opencode", cwd)
        if opencode_terminal and opencode_terminal:buf_valid() then
          return opencode_terminal
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
          "<M-Tab>",
          function()
            vim.cmd.tabnext()
          end,
          mode = { "n", "t" },
          desc = "Next tab",
        },
        {
          "<leader>ao",
          function()
            toggle_terminal("opencode")
          end,
          desc = "Toggle opencode",
        },
        {
          "<leader>ac",
          function()
            toggle_terminal("claude")
          end,
          desc = "Toggle claude",
        },
        {
          "<leader>ax",
          function()
            toggle_terminal("codex")
          end,
          desc = "Toggle codex",
        },
        {
          "<leader>af",
          function()
            send_reference(current_file_reference())
          end,
          desc = "Reference current file",
        },
        {
          "<leader>al",
          function()
            send_reference(current_line_reference())
          end,
          desc = "Reference current line",
        },
        {
          "<leader>as",
          function()
            send_reference(current_selection_reference())
          end,
          mode = "x",
          desc = "Reference selection",
        },
      }
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
