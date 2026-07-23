local M = {}

local role_order = { "nvim", "agent", "terminal" }
local hunk_terminal_config = {
  count = 1,
  cmd = { "hunk", "diff", "--watch" },
}

local workspace = {
  tabs = {},
  generation = 0,
  initializing = false,
  ready = false,
  cleaning = false,
  exiting = false,
  repair_scheduled = false,
  pending_actions = {},
  neotree_queue = {},
}

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end
  return vim.fs.normalize(vim.uv.fs_realpath(path) or path)
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
  if not valid_tabpage(tabpage) then
    return
  end
  pcall(vim.api.nvim_tabpage_set_var, tabpage, "workspace_role", role)
  local state = rawget(_G, "WorkspaceTablineState")
  if state and state.active then
    state.tabs[tabpage] = true
  end
end

local function clear_tab_role(tabpage)
  if valid_tabpage(tabpage) then
    pcall(vim.api.nvim_tabpage_del_var, tabpage, "workspace_role")
  end
  local state = rawget(_G, "WorkspaceTablineState")
  if state and state.tabs then
    state.tabs[tabpage] = nil
  end
end

local function tab_label(tabpage)
  local ok, role = pcall(vim.api.nvim_tabpage_get_var, tabpage, "workspace_role")
  if ok and type(role) == "string" then
    return role
  end

  local win = vim.api.nvim_tabpage_get_win(tabpage)
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
  return name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")
end

local function render_tabline()
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

local function install_tabline()
  if workspace.tabline ~= nil then
    return
  end
  workspace.tabline = vim.o.tabline
  workspace.showtabline = vim.o.showtabline
  _G.WorkspaceTabline = render_tabline
  _G.WorkspaceTablineState = {
    active = true,
    tabline = workspace.tabline,
    showtabline = workspace.showtabline,
    tabs = {},
  }
  vim.o.tabline = "%!v:lua.WorkspaceTabline()"
  vim.o.showtabline = 2
end

local function restore_tabline()
  if workspace.tabline ~= nil then
    vim.o.tabline = workspace.tabline
  end
  if workspace.showtabline ~= nil then
    vim.o.showtabline = workspace.showtabline
  end
  _G.WorkspaceTabline = nil
  _G.WorkspaceTablineState = nil
  workspace.tabline = nil
  workspace.showtabline = nil
end

local function close_tabpage(tabpage)
  if not valid_tabpage(tabpage) then
    return
  end
  local tab_number = vim.api.nvim_tabpage_get_number(tabpage)
  pcall(vim.cmd, "silent! tabclose " .. tab_number)
end

local function create_help_buffer(kind)
  local lines
  if kind == "agent" then
    lines = {
      "Agent workspace",
      "",
      "Choose an agent:",
      "  Alt-o  OpenCode",
      "  Alt-c  Claude Code",
      "",
      "Workspace tabs:",
      "  Alt-n  Neovim",
      "  Alt-a  Agent + Hunk",
      "  Alt-t  Terminal",
    }
  elseif kind == "hunk" then
    lines = {
      "Hunk watcher is not running.",
      "",
      "Focus the agent tab again to retry.",
    }
  else
    lines = {
      "Shell is not running.",
      "",
      "Press Alt-t to start a new shell.",
    }
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "agent-workspace"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  return buf
end

local function show_help(win, kind)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return nil
  end
  local buf = create_help_buffer(kind)
  vim.api.nvim_win_set_buf(win, buf)
  vim.wo[win].winbar = kind
  return buf
end

local function is_neotree_window(win)
  return vim.api.nvim_win_is_valid(win) and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree"
end

local function content_window(tabpage)
  if not valid_tabpage(tabpage) then
    return nil
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    if not is_neotree_window(win) then
      return win
    end
  end
end

local function ensure_content_window(tabpage, kind)
  local win = content_window(tabpage)
  if win then
    return win
  end
  vim.api.nvim_set_current_tabpage(tabpage)
  vim.cmd("botright vnew")
  win = vim.api.nvim_get_current_win()
  if kind == "nvim" then
    vim.wo[win].winbar = ""
  else
    show_help(win, kind)
  end
  return win
end

local function protect_initial_scratch_buffer(win)
  if vim.fn.argc() ~= 0 or not window_in_tabpage(win, workspace.tabs.nvim) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  if
    vim.api.nvim_buf_get_name(buf) ~= ""
    or vim.bo[buf].buftype ~= ""
    or vim.bo[buf].filetype ~= ""
    or vim.bo[buf].modified
    or vim.api.nvim_buf_line_count(buf) ~= 1
    or vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= ""
  then
    return
  end

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
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

local function restore_request_focus(request)
  if not request.started or not valid_tabpage(request.restore_tabpage) then
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  local request_still_owns_focus = current_tabpage() == request.tabpage
    and (current_win == request.focus_win or is_neotree_window(current_win))
  if not request_still_owns_focus then
    return
  end

  pcall(vim.api.nvim_set_current_tabpage, request.restore_tabpage)
  if window_in_tabpage(request.restore_win, request.restore_tabpage) then
    pcall(vim.api.nvim_set_current_win, request.restore_win)
  end
end

local function finish_neotree_request(request, success, message)
  if request.done then
    return
  end
  request.done = true
  cleanup_neotree_request(request)
  if workspace.neotree_active == request then
    workspace.neotree_active = nil
  end
  restore_request_focus(request)

  if
    not success
    and message
    and request.generation == workspace.generation
    and not workspace.cleaning
    and not workspace.neotree_warning_shown
  then
    workspace.neotree_warning_shown = true
    vim.notify("Could not open Neo-tree in the Neovim workspace: " .. message, vim.log.levels.WARN)
  end
  vim.defer_fn(run_next_neotree_request, 100)
end

local function verify_neotree_request(request)
  if request.done or request.generation ~= workspace.generation or workspace.cleaning then
    return
  end
  if filesystem_neotree_window(request.tabpage, request.cwd) then
    finish_neotree_request(request, true)
  end
end

run_next_neotree_request = function()
  if workspace.neotree_active or workspace.cleaning or workspace.exiting then
    return
  end

  local request = table.remove(workspace.neotree_queue, 1)
  while request and request.generation ~= workspace.generation do
    request = table.remove(workspace.neotree_queue, 1)
  end
  if not request then
    return
  end
  if not valid_tabpage(request.tabpage) then
    finish_neotree_request(request, false, "target tab is unavailable")
    return
  end

  workspace.neotree_active = request
  request.started = true
  request.restore_tabpage = current_tabpage()
  request.restore_win = vim.api.nvim_get_current_win()
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    pcall(lazy.load, { plugins = { "neo-tree.nvim" } })
  end
  local events_ok, events = pcall(require, "neo-tree.events")
  local command_ok, command = pcall(require, "neo-tree.command")
  if not events_ok or not command_ok then
    finish_neotree_request(request, false, tostring(events_ok and command or events))
    return
  end

  vim.api.nvim_set_current_tabpage(request.tabpage)
  if window_in_tabpage(request.focus_win, request.tabpage) then
    vim.api.nvim_set_current_win(request.focus_win)
  end
  if filesystem_neotree_window(request.tabpage, request.cwd) then
    finish_neotree_request(request, true)
    return
  end

  request.events = events
  request.subscription = {
    event = events.NEO_TREE_WINDOW_AFTER_OPEN,
    id = "workspace_neotree_" .. request.generation .. "_" .. tostring(request.tabpage),
    handler = function(args)
      if
        not request.done
        and valid_tabpage(request.tabpage)
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
  local subscribed, subscribe_error = pcall(events.subscribe, request.subscription)
  if not subscribed then
    finish_neotree_request(request, false, tostring(subscribe_error))
    return
  end

  request.timer = vim.uv.new_timer()
  if request.timer then
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
  end

  local executed, execute_error = pcall(command.execute, {
    action = "show",
    source = "filesystem",
    position = "left",
    dir = request.cwd,
  })
  if not executed then
    finish_neotree_request(request, false, tostring(execute_error))
    return
  end
  vim.schedule(function()
    verify_neotree_request(request)
  end)
end

local function queue_neotree(tabpage, cwd, focus_win)
  if not valid_tabpage(tabpage) or filesystem_neotree_window(tabpage, cwd) then
    return
  end
  if workspace.neotree_active and workspace.neotree_active.tabpage == tabpage then
    return
  end
  for _, request in ipairs(workspace.neotree_queue) do
    if request.tabpage == tabpage and request.generation == workspace.generation then
      return
    end
  end
  workspace.neotree_queue[#workspace.neotree_queue + 1] = {
    tabpage = tabpage,
    cwd = cwd,
    focus_win = focus_win,
    generation = workspace.generation,
  }
  run_next_neotree_request()
end

local function cancel_neotree_requests()
  workspace.neotree_queue = {}
  if workspace.neotree_active then
    local request = workspace.neotree_active
    request.done = true
    cleanup_neotree_request(request)
    workspace.neotree_active = nil
  end
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

local function job_is_running(job_id)
  if type(job_id) ~= "number" or job_id <= 0 then
    return false
  end
  local ok, result = pcall(vim.fn.jobwait, { job_id }, 0)
  return ok and result[1] == -1
end

local function terminal_is_running(terminal)
  return job_is_running(terminal_job_id(terminal))
end

local function stop_terminal_job(terminal)
  local job_id = terminal_job_id(terminal)
  if job_is_running(job_id) then
    pcall(vim.fn.jobstop, job_id)
  end
end

local function detach_terminal_window(terminal)
  if terminal and terminal.win and not terminal:valid() then
    terminal.win = nil
  end
end

local function close_terminal(terminal)
  if not terminal then
    return
  end
  stop_terminal_job(terminal)
  detach_terminal_window(terminal)
  if terminal:buf_valid() then
    pcall(terminal.close, terminal)
  end
end

local function get_hunk_terminal(create)
  local opts = {
    count = hunk_terminal_config.count,
    cwd = workspace.cwd,
    interactive = false,
    auto_close = false,
    auto_insert = false,
    start_insert = false,
    win = {
      position = "current",
      bo = {
        bufhidden = "hide",
      },
      wo = {
        winbar = "hunk",
      },
    },
  }
  if create ~= nil then
    opts.create = create
  end
  return Snacks.terminal.get(hunk_terminal_config.cmd, opts)
end

local function resize_agent_panes()
  local tabpage = workspace.tabs.agent
  if not window_in_tabpage(workspace.agent_win, tabpage) or not window_in_tabpage(workspace.hunk_win, tabpage) then
    return
  end
  local total_width = vim.api.nvim_win_get_width(workspace.agent_win)
    + vim.api.nvim_win_get_width(workspace.hunk_win)
    + 1
  local agent_width = math.max(vim.o.winminwidth, math.floor(total_width * 0.5))
  if vim.api.nvim_win_get_width(workspace.agent_win) ~= agent_width then
    pcall(vim.api.nvim_win_set_width, workspace.agent_win, agent_width)
  end
end

local function agent_layout_is_valid()
  local tabpage = workspace.tabs.agent
  if
    not valid_tabpage(tabpage)
    or not window_in_tabpage(workspace.agent_win, tabpage)
    or not window_in_tabpage(workspace.hunk_win, tabpage)
    or workspace.agent_win == workspace.hunk_win
  then
    return false
  end

  local wins = vim.api.nvim_tabpage_list_wins(tabpage)
  if #wins ~= 2 then
    return false
  end

  local agent_config = vim.api.nvim_win_get_config(workspace.agent_win)
  local hunk_config = vim.api.nvim_win_get_config(workspace.hunk_win)
  if agent_config.relative ~= "" or hunk_config.relative ~= "" then
    return false
  end

  local agent_position = vim.api.nvim_win_get_position(workspace.agent_win)
  local hunk_position = vim.api.nvim_win_get_position(workspace.hunk_win)
  return agent_position[1] == hunk_position[1] and agent_position[2] < hunk_position[2]
end

local function ensure_agent_layout()
  local tabpage = workspace.tabs.agent
  if not valid_tabpage(tabpage) then
    return false
  end

  local wins = vim.api.nvim_tabpage_list_wins(tabpage)
  if agent_layout_is_valid() then
    resize_agent_panes()
    return false
  end

  if workspace.agent_manager then
    workspace.agent_manager.detach_window()
  end
  if workspace.hunk_terminal then
    workspace.hunk_terminal.win = nil
  end

  vim.api.nvim_set_current_tabpage(tabpage)
  local base = wins[1]
  if not base then
    vim.cmd("enew")
    base = vim.api.nvim_get_current_win()
  end
  vim.api.nvim_set_current_win(base)
  for _, win in ipairs(wins) do
    if win ~= base and vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end

  workspace.agent_win = base
  show_help(workspace.agent_win, "agent")
  vim.api.nvim_set_current_win(workspace.agent_win)
  vim.cmd("rightbelow vnew")
  workspace.hunk_win = vim.api.nvim_get_current_win()
  show_help(workspace.hunk_win, "hunk")
  resize_agent_panes()
  return true
end

local function register_hunk_terminal(terminal)
  if not terminal or not terminal:buf_valid() or vim.b[terminal.buf].workspace_hunk_registered then
    return
  end
  vim.b[terminal.buf].workspace_hunk_registered = true
  vim.api.nvim_create_autocmd("TermClose", {
    group = workspace.augroup,
    buffer = terminal.buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if workspace.cleaning or workspace.exiting or workspace.hunk_terminal ~= terminal then
          return
        end
        terminal.win = nil
        workspace.hunk_terminal = nil
        if window_in_tabpage(workspace.hunk_win, workspace.tabs.agent) then
          show_help(workspace.hunk_win, "hunk")
        end
      end)
    end,
  })
end

local function start_hunk_watcher()
  local tabpage = workspace.tabs.agent
  if not valid_tabpage(tabpage) or not window_in_tabpage(workspace.hunk_win, tabpage) then
    return false
  end
  vim.api.nvim_set_current_tabpage(tabpage)
  vim.api.nvim_set_current_win(workspace.hunk_win)

  local watcher = workspace.hunk_terminal
  if watcher and not terminal_is_running(watcher) then
    close_terminal(watcher)
    watcher = nil
  end
  watcher = watcher or get_hunk_terminal(false)
  if watcher and not terminal_is_running(watcher) then
    close_terminal(watcher)
    watcher = nil
  end
  if not watcher then
    watcher = get_hunk_terminal()
  else
    detach_terminal_window(watcher)
    watcher:show()
  end

  if not watcher or not terminal_is_running(watcher) or not window_shows_buffer(watcher.win, tabpage, watcher.buf) then
    if watcher then
      close_terminal(watcher)
    end
    show_help(workspace.hunk_win, "hunk")
    return false
  end

  workspace.hunk_terminal = watcher
  workspace.hunk_win = watcher.win
  register_hunk_terminal(watcher)
  return true
end

local function stop_shell()
  if job_is_running(workspace.shell_job) then
    pcall(vim.fn.jobstop, workspace.shell_job)
  end
  workspace.shell_job = nil
  if workspace.shell_buf and vim.api.nvim_buf_is_valid(workspace.shell_buf) then
    pcall(vim.api.nvim_buf_delete, workspace.shell_buf, { force = true })
  end
  workspace.shell_buf = nil
  workspace.shell_win = nil
end

local function start_shell()
  local tabpage = workspace.tabs.terminal
  if not valid_tabpage(tabpage) then
    return false
  end
  local win = ensure_content_window(tabpage, "terminal")
  vim.api.nvim_set_current_tabpage(tabpage)
  vim.api.nvim_set_current_win(win)

  if workspace.shell_buf and vim.api.nvim_buf_is_valid(workspace.shell_buf) and job_is_running(workspace.shell_job) then
    vim.api.nvim_win_set_buf(win, workspace.shell_buf)
    workspace.shell_win = win
    return true
  end
  stop_shell()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.api.nvim_win_set_buf(win, buf)
  vim.wo[win].winbar = "terminal"
  local job_id = vim.api.nvim_buf_call(buf, function()
    return vim.fn.jobstart({ vim.o.shell }, {
      cwd = workspace.cwd,
      term = true,
    })
  end)
  if type(job_id) ~= "number" or job_id <= 0 then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    show_help(win, "terminal")
    return false
  end

  workspace.shell_buf = buf
  workspace.shell_win = win
  workspace.shell_job = job_id
  vim.api.nvim_create_autocmd("TermClose", {
    group = workspace.augroup,
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if workspace.cleaning or workspace.exiting or workspace.shell_buf ~= buf then
          return
        end
        workspace.shell_job = nil
        workspace.shell_buf = nil
        workspace.shell_win = nil
        local terminal_win = content_window(workspace.tabs.terminal)
        if terminal_win then
          show_help(terminal_win, "terminal")
        end
        if vim.api.nvim_buf_is_valid(buf) then
          pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
      end)
    end,
  })
  return true
end

local function snacks_available()
  if rawget(_G, "Snacks") then
    return true
  end
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    pcall(lazy.load, { plugins = { "snacks.nvim" } })
  end
  pcall(require, "snacks")
  return rawget(_G, "Snacks") ~= nil
end

local function create_tab_after(previous, role)
  if valid_tabpage(previous) then
    vim.api.nvim_set_current_tabpage(previous)
  end
  vim.cmd.tabnew()
  local tabpage = current_tabpage()
  workspace.tabs[role] = tabpage
  set_tab_role(tabpage, role)
  return tabpage, vim.api.nvim_get_current_win()
end

local function find_unmanaged_tab()
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local managed = false
    for _, role in ipairs(role_order) do
      if workspace.tabs[role] == tabpage then
        managed = true
        break
      end
    end
    if not managed then
      return tabpage
    end
  end
end

local function reorder_workspace_tabs()
  for index, role in ipairs(role_order) do
    local tabpage = workspace.tabs[role]
    if valid_tabpage(tabpage) then
      vim.api.nvim_set_current_tabpage(tabpage)
      pcall(vim.cmd, "silent! tabmove " .. (index - 1))
    end
  end
end

local function flush_pending_actions()
  local pending = workspace.pending_actions
  workspace.pending_actions = {}
  for _, callback in ipairs(pending) do
    vim.schedule(callback)
  end
end

local function ensure_workspace(initial)
  if workspace.cleaning or workspace.exiting or workspace.initializing then
    return workspace.ready
  end
  if not snacks_available() then
    return false
  end

  workspace.cwd = workspace.cwd or vim.fn.getcwd(0, 0)
  workspace.initializing = true
  local restore_tabpage = current_tabpage()
  local restore_win = vim.api.nvim_get_current_win()
  local nvim_was_missing = not valid_tabpage(workspace.tabs.nvim)
  local agent_was_missing = not valid_tabpage(workspace.tabs.agent)
  local terminal_was_missing = not valid_tabpage(workspace.tabs.terminal)

  install_tabline()
  if nvim_was_missing then
    workspace.tabs.nvim = find_unmanaged_tab() or create_tab_after(nil, "nvim")
    set_tab_role(workspace.tabs.nvim, "nvim")
  end
  workspace.nvim_win = ensure_content_window(workspace.tabs.nvim, "nvim")
  if initial then
    protect_initial_scratch_buffer(workspace.nvim_win)
  end

  if agent_was_missing then
    local tabpage, win = create_tab_after(workspace.tabs.nvim, "agent")
    workspace.tabs.agent = tabpage
    workspace.agent_win = win
    workspace.hunk_win = nil
  end
  local agent_layout_rebuilt = ensure_agent_layout()

  if terminal_was_missing then
    local tabpage, win = create_tab_after(workspace.tabs.agent, "terminal")
    workspace.tabs.terminal = tabpage
    if
      workspace.shell_buf
      and vim.api.nvim_buf_is_valid(workspace.shell_buf)
      and job_is_running(workspace.shell_job)
    then
      vim.api.nvim_win_set_buf(win, workspace.shell_buf)
      workspace.shell_win = win
    else
      start_shell()
    end
  elseif not window_shows_buffer(workspace.shell_win, workspace.tabs.terminal, workspace.shell_buf) then
    local terminal_win = ensure_content_window(workspace.tabs.terminal, "terminal")
    if
      workspace.shell_buf
      and vim.api.nvim_buf_is_valid(workspace.shell_buf)
      and job_is_running(workspace.shell_job)
    then
      vim.api.nvim_win_set_buf(terminal_win, workspace.shell_buf)
      workspace.shell_win = terminal_win
    end
  end

  if
    not workspace.hunk_terminal
    or not terminal_is_running(workspace.hunk_terminal)
    or not window_shows_buffer(workspace.hunk_terminal.win, workspace.tabs.agent, workspace.hunk_terminal.buf)
  then
    start_hunk_watcher()
  end

  for _, role in ipairs(role_order) do
    set_tab_role(workspace.tabs[role], role)
  end
  reorder_workspace_tabs()

  workspace.ready = true
  workspace.initializing = false
  if workspace.agent_manager and (initial or agent_was_missing or agent_layout_rebuilt) then
    workspace.agent_manager.ensure_visible({ default = initial and "opencode" or nil })
  end

  local focus_tabpage = initial and workspace.tabs.nvim or restore_tabpage
  local focus_win = initial and workspace.nvim_win or restore_win
  if not valid_tabpage(focus_tabpage) then
    focus_tabpage = workspace.tabs.nvim
    focus_win = workspace.nvim_win
  end
  if valid_tabpage(focus_tabpage) then
    vim.api.nvim_set_current_tabpage(focus_tabpage)
    if window_in_tabpage(focus_win, focus_tabpage) then
      vim.api.nvim_set_current_win(focus_win)
    end
  end

  if initial and current_tabpage() == workspace.tabs.nvim then
    vim.cmd.stopinsert()
    vim.schedule(function()
      if not workspace.cleaning and current_tabpage() == workspace.tabs.nvim then
        vim.cmd.stopinsert()
      end
    end)
  end

  queue_neotree(workspace.tabs.nvim, workspace.cwd, workspace.nvim_win)
  flush_pending_actions()
  return true
end

function M.schedule_repair()
  if workspace.repair_scheduled or workspace.cleaning or workspace.exiting then
    return
  end
  workspace.repair_scheduled = true
  vim.schedule(function()
    workspace.repair_scheduled = false
    if not workspace.cleaning and not workspace.exiting then
      ensure_workspace(false)
    end
  end)
end

local function request_initialization()
  if workspace.cleaning or workspace.exiting or workspace.ready then
    return
  end
  vim.schedule(function()
    if workspace.cleaning or workspace.exiting or workspace.ready then
      return
    end
    if not ensure_workspace(true) then
      workspace.init_attempts = (workspace.init_attempts or 0) + 1
      if workspace.init_attempts < 20 then
        vim.defer_fn(request_initialization, 100)
      else
        vim.notify("Agent workspace could not initialize because Snacks is unavailable", vim.log.levels.WARN)
      end
    end
  end)
end

function M.run_when_ready(callback)
  if workspace.ready and ensure_workspace(false) then
    callback()
    return
  end
  workspace.pending_actions[#workspace.pending_actions + 1] = callback
  request_initialization()
end

function M.cwd()
  workspace.cwd = workspace.cwd or vim.fn.getcwd(0, 0)
  return workspace.cwd
end

function M.agent_pane()
  if not window_in_tabpage(workspace.agent_win, workspace.tabs.agent) then
    return nil, nil
  end
  return workspace.tabs.agent, workspace.agent_win
end

function M.show_agent_help()
  if window_in_tabpage(workspace.agent_win, workspace.tabs.agent) then
    show_help(workspace.agent_win, "agent")
  end
end

local function focus_role(role)
  M.run_when_ready(function()
    local tabpage = workspace.tabs[role]
    if not valid_tabpage(tabpage) then
      M.schedule_repair()
      return
    end
    vim.api.nvim_set_current_tabpage(tabpage)
    if role == "agent" then
      if
        not workspace.hunk_terminal
        or not terminal_is_running(workspace.hunk_terminal)
        or not window_shows_buffer(workspace.hunk_terminal.win, tabpage, workspace.hunk_terminal.buf)
      then
        start_hunk_watcher()
      end
      if not workspace.agent_manager or not workspace.agent_manager.focus() then
        vim.api.nvim_set_current_win(workspace.agent_win)
      end
    elseif role == "terminal" then
      if not job_is_running(workspace.shell_job) then
        start_shell()
      end
      if window_in_tabpage(workspace.shell_win, tabpage) then
        vim.api.nvim_set_current_win(workspace.shell_win)
        vim.cmd.startinsert()
      end
    else
      workspace.nvim_win = ensure_content_window(tabpage, "nvim")
      vim.api.nvim_set_current_win(workspace.nvim_win)
    end
  end)
end

function M.cleanup(opts)
  opts = opts or {}
  if workspace.cleaning then
    return
  end
  workspace.cleaning = true
  workspace.exiting = opts.exit == true
  workspace.generation = workspace.generation + 1
  cancel_neotree_requests()

  if workspace.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, workspace.augroup)
    workspace.augroup = nil
  end
  if workspace.hunk_terminal then
    close_terminal(workspace.hunk_terminal)
    workspace.hunk_terminal = nil
  end
  stop_shell()

  local nvim_tabpage = workspace.tabs.nvim
  if not opts.exit and valid_tabpage(nvim_tabpage) then
    pcall(vim.api.nvim_set_current_tabpage, nvim_tabpage)
  end
  for _, role in ipairs({ "terminal", "agent" }) do
    close_tabpage(workspace.tabs[role])
  end
  clear_tab_role(nvim_tabpage)
  restore_tabline()
  workspace.ready = false
end

function M.setup(opts)
  workspace.agent_manager = opts.agent_manager
  workspace.cleanup = opts.cleanup
  workspace.augroup = vim.api.nvim_create_augroup("workspace_tabs", { clear = true })
  vim.api.nvim_create_autocmd({ "TabClosed", "WinClosed", "WinNew" }, {
    group = workspace.augroup,
    callback = M.schedule_repair,
  })
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = workspace.augroup,
    callback = function()
      vim.schedule(function()
        if agent_layout_is_valid() then
          resize_agent_panes()
        else
          M.schedule_repair()
        end
      end)
    end,
  })
  vim.api.nvim_create_autocmd("WinScrolled", {
    group = workspace.augroup,
    callback = function(args)
      local changes = args.data or vim.v.event.all or {}
      local size_changed = (changes.width or 0) ~= 0 or (changes.height or 0) ~= 0
      if current_tabpage() ~= workspace.tabs.agent or not size_changed then
        return
      end
      if agent_layout_is_valid() then
        vim.schedule(resize_agent_panes)
      else
        M.schedule_repair()
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "TabEnter", "WinEnter" }, {
    group = workspace.augroup,
    callback = function()
      if current_tabpage() == workspace.tabs.agent and not agent_layout_is_valid() then
        M.schedule_repair()
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = workspace.augroup,
    once = true,
    callback = function()
      workspace.cleanup({ exit = true })
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = workspace.augroup,
    pattern = "VeryLazy",
    once = true,
    callback = request_initialization,
  })

  if vim.v.vim_did_enter == 1 then
    request_initialization()
  end
end

function M.keys()
  return {
    {
      "<M-1>",
      function()
        focus_role("nvim")
      end,
      mode = { "n", "t" },
      desc = "Focus Neovim tab",
    },
    {
      "<M-2>",
      function()
        focus_role("agent")
      end,
      mode = { "n", "t" },
      desc = "Focus agent tab",
    },
    {
      "<M-3>",
      function()
        focus_role("terminal")
      end,
      mode = { "n", "t" },
      desc = "Focus terminal tab",
    },
  }
end

return M
