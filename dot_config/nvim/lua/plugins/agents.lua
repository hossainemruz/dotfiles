return {
  {
    "folke/snacks.nvim",
    keys = function()
      local last_terminal_name
      local last_terminal_cwd
      local close_agent_panel
      local agent_panel_is_open
      local agent_panel_cleanup
      local schedule_macos_hunk_cleanup
      local ensure_return_tab

      local uname_ok, uname = pcall(vim.uv.os_uname)
      local is_macos = uname_ok and uname and uname.sysname == "Darwin"

      local previous_cleanup = rawget(_G, "AgentWorkspaceReloadCleanup")
      if type(previous_cleanup) == "function" then
        pcall(previous_cleanup)
      end
      _G.AgentWorkspaceReloadCleanup = nil
      local previous_tabline = rawget(_G, "AgentWorkspaceTablineState")
      if previous_tabline and previous_tabline.active then
        vim.o.tabline = previous_tabline.tabline
        vim.o.showtabline = previous_tabline.showtabline
        for tabpage in pairs(previous_tabline.tabs or {}) do
          if vim.api.nvim_tabpage_is_valid(tabpage) then
            pcall(vim.api.nvim_tabpage_del_var, tabpage, "agent_workspace_role")
          end
        end
      end
      _G.AgentWorkspaceTabline = nil
      _G.AgentWorkspaceTablineState = nil

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
        opening = false,
        generation = 0,
        neotree_queue = {},
      }
      local diff_jobs = {}

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

      local function window_in_tabpage(win, tabpage)
        return valid_tabpage(tabpage)
          and win
          and vim.api.nvim_win_is_valid(win)
          and vim.api.nvim_win_get_tabpage(win) == tabpage
      end

      local function window_shows_buffer(win, tabpage, buf)
        return window_in_tabpage(win, tabpage)
          and buf
          and vim.api.nvim_buf_is_valid(buf)
          and vim.api.nvim_win_get_buf(win) == buf
      end

      local function set_tab_role(tabpage, role)
        if valid_tabpage(tabpage) then
          pcall(vim.api.nvim_tabpage_set_var, tabpage, "agent_workspace_role", role)
          local state = rawget(_G, "AgentWorkspaceTablineState")
          if state and state.active then
            state.tabs[tabpage] = true
          end
        end
      end

      local function clear_tab_role(tabpage)
        if valid_tabpage(tabpage) then
          pcall(vim.api.nvim_tabpage_del_var, tabpage, "agent_workspace_role")
          local state = rawget(_G, "AgentWorkspaceTablineState")
          if state and state.tabs then
            state.tabs[tabpage] = nil
          end
        end
      end

      local function tab_label(tabpage)
        local ok, role = pcall(vim.api.nvim_tabpage_get_var, tabpage, "agent_workspace_role")
        if ok and type(role) == "string" then
          return role
        end

        local win = vim.api.nvim_tabpage_get_win(tabpage)
        local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
        return name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
      end

      local function render_agent_workspace_tabline()
        local current = current_tabpage()
        local parts = {}
        for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
          local highlight = tabpage == current and "%#TabLineSel#" or "%#TabLine#"
          local tab_number = vim.api.nvim_tabpage_get_number(tabpage)
          local label = tab_label(tabpage):gsub("%%", "%%%%")
          parts[#parts + 1] = string.format("%s%%%dT %s ", highlight, tab_number, label)
        end
        parts[#parts + 1] = "%#TabLineFill#%T"
        return table.concat(parts)
      end

      local function install_agent_workspace_tabline()
        agent_panel.tabline = vim.o.tabline
        agent_panel.showtabline = vim.o.showtabline
        _G.AgentWorkspaceTabline = render_agent_workspace_tabline
        _G.AgentWorkspaceTablineState = {
          active = true,
          tabline = agent_panel.tabline,
          showtabline = agent_panel.showtabline,
          tabs = {},
        }
        vim.o.tabline = "%!v:lua.AgentWorkspaceTabline()"
        vim.o.showtabline = 2
      end

      local function restore_agent_workspace_tabline()
        if agent_panel.tabline ~= nil then
          vim.o.tabline = agent_panel.tabline
        end
        if agent_panel.showtabline ~= nil then
          vim.o.showtabline = agent_panel.showtabline
        end
        _G.AgentWorkspaceTabline = nil
        _G.AgentWorkspaceTablineState = nil
      end

      local function filesystem_neotree_window(tabpage, cwd)
        if not valid_tabpage(tabpage) then
          return nil
        end

        local manager_ok, manager = pcall(require, "neo-tree.sources.manager")
        if not manager_ok then
          return nil
        end
        local expected_root = normalize_path(cwd)
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
          local buf = vim.api.nvim_win_get_buf(win)
          local source_ok, source = pcall(function()
            return vim.b[buf].neo_tree_source
          end)
          local position_ok, position = pcall(function()
            return vim.b[buf].neo_tree_position
          end)
          local state_ok, state = pcall(manager.get_state, "filesystem", tabpage, nil)
          if
            vim.bo[buf].filetype == "neo-tree"
            and source_ok
            and source == "filesystem"
            and position_ok
            and position == "left"
            and state_ok
            and state
            and normalize_path(state.path) == expected_root
          then
            return win
          end
        end
      end

      local run_next_neotree_request

      local function cleanup_neotree_request(request)
        if request.subscription and request.events then
          pcall(request.events.unsubscribe, request.subscription)
          request.subscription = nil
        end
        if request.timer then
          pcall(request.timer.stop, request.timer)
          if not request.timer:is_closing() then
            pcall(request.timer.close, request.timer)
          end
          request.timer = nil
        end
      end

      local function finish_neotree_request(request, success, message)
        if request.done then
          return
        end
        request.done = true
        cleanup_neotree_request(request)
        if agent_panel.neotree_active == request then
          agent_panel.neotree_active = nil
        end
        agent_panel.neotree_between_requests = true

        if not success and message and request.generation == agent_panel.generation then
          vim.notify("Could not open Neo-tree: " .. message, vim.log.levels.WARN)
        end
        if window_in_tabpage(request.focus_win, request.tabpage) then
          vim.api.nvim_set_current_tabpage(request.tabpage)
          vim.api.nvim_set_current_win(request.focus_win)
        end

        if request.generation == agent_panel.generation and not agent_panel.closing then
          local callback_ok, callback_error = pcall(request.callback, success)
          if not callback_ok then
            vim.notify("Agent workspace setup failed: " .. tostring(callback_error), vim.log.levels.ERROR)
          end
        end
        vim.defer_fn(function()
          agent_panel.neotree_between_requests = false
          run_next_neotree_request()
        end, 150)
      end

      local function verify_neotree_request(request)
        if request.done or request.generation ~= agent_panel.generation or agent_panel.closing then
          return
        end
        local win = filesystem_neotree_window(request.tabpage, request.cwd)
        if win then
          finish_neotree_request(request, true)
        end
      end

      run_next_neotree_request = function()
        if agent_panel.neotree_active or agent_panel.neotree_between_requests or agent_panel.closing then
          return
        end

        local request = table.remove(agent_panel.neotree_queue, 1)
        while request and request.generation ~= agent_panel.generation do
          request = table.remove(agent_panel.neotree_queue, 1)
        end
        if not request then
          return
        end
        if not valid_tabpage(request.tabpage) then
          finish_neotree_request(request, false, "target tab is unavailable")
          return
        end

        agent_panel.neotree_active = request
        vim.api.nvim_set_current_tabpage(request.tabpage)
        if window_in_tabpage(request.focus_win, request.tabpage) then
          vim.api.nvim_set_current_win(request.focus_win)
        end

        if filesystem_neotree_window(request.tabpage, request.cwd) then
          vim.schedule(function()
            if filesystem_neotree_window(request.tabpage, request.cwd) then
              finish_neotree_request(request, true)
            else
              finish_neotree_request(request, false, "existing filesystem window became unavailable")
            end
          end)
          return
        end

        local events_ok, events = pcall(require, "neo-tree.events")
        local command_ok, command = pcall(require, "neo-tree.command")
        if not events_ok or not command_ok then
          finish_neotree_request(request, false, tostring(events_ok and command or events))
          return
        end

        request.events = events
        request.subscription = {
          event = events.NEO_TREE_WINDOW_AFTER_OPEN,
          id = "agent_workspace_neotree_" .. request.generation .. "_" .. tostring(request.tabpage),
          handler = function(args)
            if
              valid_tabpage(request.tabpage)
              and not request.done
              and args.source == "filesystem"
              and args.position == "left"
              and (args.tabid == request.tabpage or args.tabnr == vim.api.nvim_tabpage_get_number(request.tabpage))
            then
              vim.schedule(function()
                verify_neotree_request(request)
              end)
            end
          end,
        }
        events.subscribe(request.subscription)

        request.timer = vim.uv.new_timer()
        request.deadline = vim.uv.hrtime() + 2000000000
        request.timer:start(
          25,
          25,
          vim.schedule_wrap(function()
            if request.done then
              return
            end
            verify_neotree_request(request)
            if not request.done and vim.uv.hrtime() >= request.deadline then
              finish_neotree_request(request, false, "timed out waiting for its filesystem window")
            end
          end)
        )

        local executed, error_message = pcall(command.execute, {
          action = "show",
          source = "filesystem",
          position = "left",
          dir = request.cwd,
        })
        if not executed then
          finish_neotree_request(request, false, tostring(error_message))
          return
        end
        vim.schedule(function()
          verify_neotree_request(request)
        end)
      end

      local function queue_neotree(tabpage, cwd, focus_win, callback)
        agent_panel.neotree_queue[#agent_panel.neotree_queue + 1] = {
          tabpage = tabpage,
          cwd = cwd,
          focus_win = focus_win,
          callback = callback,
          generation = agent_panel.generation,
        }
        run_next_neotree_request()
      end

      local function cancel_neotree_requests()
        agent_panel.neotree_queue = {}
        agent_panel.neotree_between_requests = false
        if agent_panel.neotree_active then
          local request = agent_panel.neotree_active
          request.done = true
          cleanup_neotree_request(request)
          agent_panel.neotree_active = nil
        end
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
            wo = {
              winbar = "agent",
            },
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

      local function terminal_job_id(terminal)
        if not terminal or not terminal:buf_valid() then
          return nil
        end

        local ok, job_id = pcall(function()
          return vim.b[terminal.buf].terminal_job_id
        end)

        if ok and type(job_id) == "number" and job_id > 0 then
          return job_id
        end
      end

      local function stop_terminal_job(terminal, fallback_job_id)
        local job_id = terminal_job_id(terminal) or fallback_job_id
        if job_id then
          pcall(vim.fn.jobstop, job_id)
        end
      end

      local function stop_diff_terminal(terminal)
        if not terminal then
          return
        end

        stop_terminal_job(terminal, diff_jobs[terminal])
        diff_jobs[terminal] = nil
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

      agent_panel_is_open = function()
        return valid_tabpage(agent_panel.tabpage)
      end

      agent_panel_cleanup = vim.api.nvim_create_augroup("agent_panel_cleanup", { clear = true })
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = agent_panel_cleanup,
        callback = function()
          for terminal in pairs(diff_jobs) do
            stop_diff_terminal(terminal)
          end
        end,
      })
      vim.api.nvim_create_autocmd("TabClosed", {
        group = agent_panel_cleanup,
        callback = function()
          vim.schedule(function()
            if agent_panel.neotree_active and not valid_tabpage(agent_panel.neotree_active.tabpage) then
              finish_neotree_request(agent_panel.neotree_active, false, "target tab was closed")
            end
            if
              is_macos
              and agent_panel.hunk_tabpage
              and not valid_tabpage(agent_panel.hunk_tabpage)
              and schedule_macos_hunk_cleanup
            then
              agent_panel.hunk_tabpage = nil
              schedule_macos_hunk_cleanup(agent_panel.diff_terminal)
            end
            if
              agent_panel.return_tabpage
              and not valid_tabpage(agent_panel.return_tabpage)
              and not agent_panel.closing
              and not agent_panel.closing_after_return_replacement
            then
              local tabpage, win = ensure_return_tab()
              agent_panel.closing_after_return_replacement = true
              queue_neotree(tabpage, agent_panel.cwd, win, function()
                if agent_panel.closing_after_return_replacement then
                  close_agent_panel()
                end
              end)
            end
          end)
        end,
      })

      local function hide_other_managed_terminals(target)
        for _, terminal in ipairs(Snacks.terminal.list()) do
          if terminal ~= target and is_managed_terminal(terminal) and terminal:valid() then
            terminal:hide()
          end
        end
      end

      local function close_tabpage(tabpage)
        if valid_tabpage(tabpage) then
          local tab_number = vim.api.nvim_tabpage_get_number(tabpage)
          pcall(vim.cmd, "silent! tabclose " .. tab_number)
        end
      end

      ensure_return_tab = function()
        if valid_tabpage(agent_panel.return_tabpage) then
          local win = agent_panel.return_win
          if not window_in_tabpage(win, agent_panel.return_tabpage) then
            win = vim.api.nvim_tabpage_get_win(agent_panel.return_tabpage)
            agent_panel.return_win = win
          end
          return agent_panel.return_tabpage, win
        end

        local replacement
        for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
          if tabpage ~= agent_panel.tabpage and tabpage ~= agent_panel.hunk_tabpage then
            replacement = tabpage
            break
          end
        end
        if replacement then
          vim.api.nvim_set_current_tabpage(replacement)
        else
          vim.cmd.tabnew()
          replacement = current_tabpage()
        end

        agent_panel.return_tabpage = replacement
        agent_panel.return_win = vim.api.nvim_get_current_win()
        set_tab_role(replacement, "nvim")
        return replacement, agent_panel.return_win
      end

      schedule_macos_hunk_cleanup = function(watcher)
        if not watcher then
          return
        end

        stop_diff_terminal(watcher)
        if agent_panel.closing or agent_panel.transitioning then
          return
        end

        vim.schedule(function()
          if agent_panel.closing or agent_panel.transitioning or agent_panel.diff_terminal ~= watcher then
            return
          end
          if watcher:win_valid() and window_shows_buffer(watcher.win, agent_panel.hunk_tabpage, watcher.buf) then
            return
          end

          local hunk_tabpage = agent_panel.hunk_tabpage
          agent_panel.diff_terminal = nil
          agent_panel.hunk_tabpage = nil
          if watcher:buf_valid() then
            watcher:close()
          end
          close_tabpage(hunk_tabpage)
        end)
      end

      local function open_macos_hunk_tab(focus)
        if not is_macos or not agent_panel_is_open() then
          return false
        end

        if
          valid_tabpage(agent_panel.hunk_tabpage)
          and agent_panel.diff_terminal
          and window_shows_buffer(
            agent_panel.diff_terminal.win,
            agent_panel.hunk_tabpage,
            agent_panel.diff_terminal.buf
          )
        then
          if focus then
            vim.api.nvim_set_current_tabpage(agent_panel.hunk_tabpage)
            agent_panel.diff_terminal:focus()
          end
          return true
        end

        local was_transitioning = agent_panel.transitioning
        agent_panel.transitioning = true
        local stale_watcher = agent_panel.diff_terminal
        local stale_hunk_tabpage = agent_panel.hunk_tabpage
        agent_panel.diff_terminal = nil
        agent_panel.hunk_tabpage = nil
        if stale_watcher then
          stop_diff_terminal(stale_watcher)
          if stale_watcher:buf_valid() then
            stale_watcher:close()
          end
        end
        close_tabpage(stale_hunk_tabpage)

        vim.api.nvim_set_current_tabpage(agent_panel.tabpage)
        vim.cmd.tabnew()
        local placeholder_buf = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_get_name(placeholder_buf) == "" and vim.bo[placeholder_buf].buftype == "" then
          vim.bo[placeholder_buf].bufhidden = "wipe"
        end
        local hunk_tabpage = current_tabpage()
        agent_panel.hunk_tabpage = hunk_tabpage
        set_tab_role(hunk_tabpage, "hunk")

        local watcher = Snacks.terminal.get(diff_terminal.cmd, {
          count = diff_terminal.count,
          cwd = agent_panel.cwd,
          interactive = false,
          auto_insert = true,
          auto_close = true,
          win = {
            position = "current",
            wo = {
              winbar = "hunk",
            },
            on_close = schedule_macos_hunk_cleanup,
          },
        })

        if not watcher or not window_shows_buffer(watcher.win, hunk_tabpage, watcher.buf) then
          if watcher then
            stop_diff_terminal(watcher)
            if watcher:buf_valid() then
              watcher:close()
            end
          end
          agent_panel.diff_terminal = nil
          agent_panel.hunk_tabpage = nil
          close_tabpage(hunk_tabpage)
          if agent_panel_is_open() then
            vim.api.nvim_set_current_tabpage(agent_panel.tabpage)
          end
          agent_panel.transitioning = was_transitioning
          vim.notify("Could not create the Hunk tab", vim.log.levels.ERROR)
          return false
        end

        agent_panel.diff_terminal = watcher
        diff_jobs[watcher] = terminal_job_id(watcher)
        vim.api.nvim_create_autocmd("TermClose", {
          group = agent_panel_cleanup,
          buffer = watcher.buf,
          once = true,
          callback = function()
            schedule_macos_hunk_cleanup(watcher)
          end,
        })
        agent_panel.transitioning = was_transitioning
        if focus then
          vim.api.nvim_set_current_tabpage(hunk_tabpage)
          watcher:focus()
        else
          vim.api.nvim_set_current_tabpage(agent_panel.tabpage)
        end
        return true
      end

      close_agent_panel = function(opts)
        opts = opts or {}
        if agent_panel.closing or (not agent_panel.tabpage and not agent_panel.opening) then
          return
        end

        agent_panel.closing = true
        agent_panel.generation = agent_panel.generation + 1
        cancel_neotree_requests()
        if not valid_tabpage(agent_panel.return_tabpage) then
          ensure_return_tab()
        end
        local panel_tabpage = agent_panel.tabpage
        local hunk_tabpage = agent_panel.hunk_tabpage
        local return_tabpage = agent_panel.return_tabpage
        local return_win = agent_panel.return_win
        local current = current_tabpage()
        local panel_was_current = (valid_tabpage(panel_tabpage) and current == panel_tabpage)
          or (valid_tabpage(hunk_tabpage) and current == hunk_tabpage)
        local terminal = agent_panel.agent_terminal
        local watcher = agent_panel.diff_terminal
        local terminal_created_for_open = agent_panel.agent_terminal_created_for_open

        agent_panel.diff_terminal = nil
        agent_panel.hunk_tabpage = nil

        if terminal then
          if opts.reload or (opts.abort and terminal_created_for_open) then
            stop_terminal_job(terminal)
            if terminal:buf_valid() then
              terminal:close()
            end
          elseif opts.abort and terminal:buf_valid() then
            terminal:hide()
          elseif
            terminal:win_valid()
            and (not is_macos or window_shows_buffer(terminal.win, panel_tabpage, terminal.buf))
          then
            terminal:hide()
          end
        end

        -- The agent session survives panel toggles, but the diff watcher should
        -- only run while the panel is visible.
        if watcher then
          stop_diff_terminal(watcher)
          if watcher:buf_valid() then
            watcher:close()
          end
        end

        close_tabpage(hunk_tabpage)
        close_tabpage(panel_tabpage)
        clear_tab_role(return_tabpage)
        restore_agent_workspace_tabline()

        agent_panel.tabpage = nil
        agent_panel.return_tabpage = nil
        agent_panel.return_win = nil
        agent_panel.agent_terminal = nil
        agent_panel.agent_terminal_created_for_open = nil
        agent_panel.diff_terminal = nil
        agent_panel.hunk_tabpage = nil
        agent_panel.cwd = nil
        agent_panel.tabline = nil
        agent_panel.showtabline = nil
        agent_panel.opening = false
        agent_panel.transitioning = false
        agent_panel.closing_after_return_replacement = false
        local ready_callbacks = agent_panel.ready_callbacks or {}
        agent_panel.ready_callbacks = {}
        agent_panel.closing = false

        if (panel_was_current or is_macos) and valid_tabpage(return_tabpage) then
          pcall(vim.api.nvim_set_current_tabpage, return_tabpage)
          if
            return_win
            and vim.api.nvim_win_is_valid(return_win)
            and vim.api.nvim_win_get_tabpage(return_win) == return_tabpage
          then
            pcall(vim.api.nvim_set_current_win, return_win)
          end
        end
        for _, callback in ipairs(ready_callbacks) do
          vim.schedule(function()
            callback(nil)
          end)
        end
      end

      _G.AgentWorkspaceReloadCleanup = function()
        close_agent_panel({ reload = true })
        for _, terminal in ipairs(Snacks.terminal.list()) do
          if is_managed_terminal(terminal) then
            stop_terminal_job(terminal)
            if terminal:buf_valid() then
              terminal:close()
            end
          end
        end
      end

      local function open_linux_hunk(terminal, cwd)
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
              winbar = "hunk",
            },
            on_close = function(diff)
              stop_diff_terminal(diff)
              schedule_panel_close(diff)
            end,
          },
        })
        if not watcher or not window_shows_buffer(watcher.win, agent_panel.tabpage, watcher.buf) then
          if watcher then
            stop_diff_terminal(watcher)
            if watcher:buf_valid() then
              watcher:close()
            end
          end
          return false
        end
        agent_panel.diff_terminal = watcher
        diff_jobs[watcher] = terminal_job_id(watcher)
        return true
      end

      local function complete_panel_open(generation, terminal)
        if
          generation ~= agent_panel.generation
          or agent_panel.closing
          or agent_panel.closing_after_return_replacement
        then
          return
        end
        if not agent_panel_is_open() or not window_shows_buffer(terminal.win, agent_panel.tabpage, terminal.buf) then
          close_agent_panel({ abort = true })
          vim.notify("Agent panel tab was lost while opening the workspace", vim.log.levels.ERROR)
          return
        end

        agent_panel.opening = false
        agent_panel.transitioning = false
        vim.api.nvim_set_current_tabpage(agent_panel.tabpage)
        terminal:focus()
        vim.cmd.startinsert()
        local callbacks = agent_panel.ready_callbacks or {}
        agent_panel.ready_callbacks = {}
        for _, callback in ipairs(callbacks) do
          vim.schedule(function()
            callback(terminal)
          end)
        end
      end

      local function abort_panel_open(generation)
        if generation == agent_panel.generation and agent_panel.opening and not agent_panel.closing then
          close_agent_panel({ abort = true })
        end
      end

      local function open_agent_panel(name, cwd, terminal, on_ready)
        if agent_panel.opening then
          if on_ready then
            agent_panel.ready_callbacks[#agent_panel.ready_callbacks + 1] = on_ready
          else
            vim.notify("Agent workspace is still opening", vim.log.levels.INFO)
          end
          return nil
        end
        if agent_panel_is_open() then
          close_agent_panel()
        end

        hide_other_managed_terminals(nil)
        agent_panel.generation = agent_panel.generation + 1
        local generation = agent_panel.generation
        local return_tabpage = current_tabpage()
        local return_win = vim.api.nvim_get_current_win()

        agent_panel.return_tabpage = return_tabpage
        agent_panel.return_win = return_win
        agent_panel.cwd = cwd
        agent_panel.opening = true
        agent_panel.transitioning = true
        agent_panel.ready_callbacks = on_ready and { on_ready } or {}
        agent_panel.agent_terminal_created_for_open = nil
        agent_panel.closing_after_return_replacement = false
        install_agent_workspace_tabline()
        set_tab_role(return_tabpage, "nvim")

        queue_neotree(return_tabpage, cwd, return_win, function(success)
          if
            generation ~= agent_panel.generation
            or agent_panel.closing
            or agent_panel.closing_after_return_replacement
          then
            return
          end
          if not success then
            abort_panel_open(generation)
            return
          end

          vim.api.nvim_set_current_tabpage(return_tabpage)
          vim.cmd.tabnew()
          local placeholder_buf = vim.api.nvim_get_current_buf()
          if vim.api.nvim_buf_get_name(placeholder_buf) == "" and vim.bo[placeholder_buf].buftype == "" then
            vim.bo[placeholder_buf].bufhidden = "wipe"
          end
          agent_panel.tabpage = current_tabpage()
          set_tab_role(agent_panel.tabpage, "agent")

          local reused_terminal = terminal and terminal:buf_valid()
          if not reused_terminal then
            terminal = get_terminal(name, cwd, false)
            reused_terminal = terminal and terminal:buf_valid()
          end
          if not reused_terminal then
            terminal = get_terminal(name, cwd, true)
          end
          if not terminal then
            close_agent_panel({ abort = true })
            vim.notify("Could not open agent terminal", vim.log.levels.ERROR)
            return
          end
          agent_panel.agent_terminal_created_for_open = not reused_terminal
          agent_panel.agent_terminal = terminal
          if not terminal:win_valid() then
            terminal:show()
          end
          if not window_shows_buffer(terminal.win, agent_panel.tabpage, terminal.buf) then
            close_agent_panel({ abort = true })
            vim.notify("Agent terminal was not created in the agent tab", vim.log.levels.ERROR)
            return
          end

          queue_neotree(agent_panel.tabpage, cwd, terminal.win, function(agent_tree_ok)
            if
              generation ~= agent_panel.generation
              or agent_panel.closing
              or agent_panel.closing_after_return_replacement
            then
              return
            end
            if not agent_tree_ok then
              abort_panel_open(generation)
              return
            end
            local hunk_ok
            if is_macos then
              hunk_ok = open_macos_hunk_tab(false)
            else
              hunk_ok = open_linux_hunk(terminal, cwd)
            end
            if not hunk_ok then
              close_agent_panel({ abort = true })
              vim.notify("Could not create Hunk", vim.log.levels.ERROR)
              return
            end
            complete_panel_open(generation, terminal)
          end)
        end)
        return nil
      end

      local function toggle_terminal(name)
        if agent_panel.opening then
          vim.notify("Agent workspace is still opening", vim.log.levels.INFO)
          return
        end
        local cwd = project_cwd()
        local terminal = get_terminal(name, cwd, false)
        remember_terminal(name, cwd)

        if agent_panel_is_open() and terminal and agent_panel.agent_terminal == terminal then
          close_agent_panel()
          return
        end

        open_agent_panel(name, cwd, terminal)
      end

      local function focus_tabpage(tabpage, label)
        if not valid_tabpage(tabpage) then
          vim.notify(label .. " tab is not available", vim.log.levels.INFO)
          return false
        end

        vim.api.nvim_set_current_tabpage(tabpage)
        return true
      end

      local function focus_return_tab()
        if agent_panel.opening then
          vim.notify("Agent workspace is still opening", vim.log.levels.INFO)
          return
        end
        if agent_panel.tabpage then
          focus_tabpage(agent_panel.return_tabpage, "Original Neovim")
          return
        end

        local first_tabpage = vim.api.nvim_list_tabpages()[1]
        focus_tabpage(first_tabpage, "First")
      end

      local function focus_agent_tab()
        if agent_panel.opening then
          vim.notify("Agent workspace is still opening", vim.log.levels.INFO)
          return
        end
        if not focus_tabpage(agent_panel.tabpage, "Agent") then
          return
        end

        local terminal = agent_panel.agent_terminal
        if terminal and window_shows_buffer(terminal.win, agent_panel.tabpage, terminal.buf) then
          terminal:focus()
        end
      end

      local function focus_hunk_tab()
        if not is_macos then
          vim.notify("A dedicated Hunk tab is only available on macOS", vim.log.levels.INFO)
          return
        end
        if not agent_panel_is_open() then
          vim.notify("Agent workspace is not open", vim.log.levels.INFO)
          return
        end
        if agent_panel.opening then
          vim.notify("Agent workspace is still opening", vim.log.levels.INFO)
          return
        end

        open_macos_hunk_tab(true)
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

        if
          agent_panel_is_open()
          and agent_panel.agent_terminal == terminal
          and window_shows_buffer(terminal.win, agent_panel.tabpage, terminal.buf)
        then
          if current_tabpage() ~= agent_panel.tabpage then
            vim.api.nvim_set_current_tabpage(agent_panel.tabpage)
          end
        else
          return false
        end

        terminal:focus()
        vim.cmd.startinsert()
        return true
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

      local function with_reference_terminal(cwd, callback)
        local terminal = reference_terminal(cwd)
        if
          terminal
          and terminal:buf_valid()
          and agent_panel_is_open()
          and agent_panel.agent_terminal == terminal
          and not agent_panel.opening
        then
          callback(terminal)
          return
        end

        if agent_panel.opening then
          agent_panel.ready_callbacks[#agent_panel.ready_callbacks + 1] = callback
          return
        end

        local name = terminal and managed_terminal_name(terminal) or "opencode"
        remember_terminal(name, cwd)
        open_agent_panel(name, cwd, terminal, callback)
      end

      local function send_reference(reference)
        if not reference then
          return
        end

        local cwd = project_cwd()
        with_reference_terminal(cwd, function(terminal)
          if not terminal then
            copy_reference(reference)
            return
          end
          if not terminal:buf_valid() or not focus_terminal(terminal) then
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
        end)
      end

      local keys = {
        {
          "<M-t>",
          function()
            if agent_panel.opening then
              vim.notify("Agent workspace is still opening", vim.log.levels.INFO)
            else
              vim.cmd.tabnext()
            end
          end,
          mode = { "n", "t" },
          desc = "Next tab",
        },
        {
          "<M-1>",
          focus_return_tab,
          mode = { "n", "t" },
          desc = "Focus original Neovim tab",
        },
        {
          "<M-2>",
          focus_agent_tab,
          mode = { "n", "t" },
          desc = "Focus agent tab",
        },
        {
          "<M-3>",
          focus_hunk_tab,
          mode = { "n", "t" },
          desc = "Focus Hunk tab",
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

      return keys
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
