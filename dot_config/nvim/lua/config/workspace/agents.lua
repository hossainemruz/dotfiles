local M = {}

local terminals = {
  opencode = {
    count = 1,
    cmd = { "env", "OPENCODE_EXPERIMENTAL_LSP_TOOL=true", "OPENCODE_ENABLE_EXA=1", "opencode" },
  },
  claude = {
    count = 3,
    cmd = { "claude" },
  },
}
local opencode_ready_markers = {
  "Ask anything",
  "General · DeepSeek V4 Pro OpenCode Go · max",
  "ctrl+p commands",
}

local state = {
  cleaning = false,
}

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end
  return vim.fs.normalize(vim.uv.fs_realpath(path) or path)
end

local function window_shows_buffer(win, tabpage, buf)
  return tabpage
    and vim.api.nvim_tabpage_is_valid(tabpage)
    and win
    and vim.api.nvim_win_is_valid(win)
    and vim.api.nvim_win_get_tabpage(win) == tabpage
    and buf
    and vim.api.nvim_buf_is_valid(buf)
    and vim.api.nvim_win_get_buf(win) == buf
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

local function terminal_command(terminal)
  if not terminal or not terminal:buf_valid() then
    return nil
  end
  local ok, data = pcall(function()
    return vim.b[terminal.buf].snacks_terminal
  end)
  if ok and data and data.cmd then
    return data.cmd
  end
  return terminal.cmd
end

local function managed_terminal_name(terminal)
  local cmd = terminal_command(terminal)
  if type(cmd) ~= "table" then
    return nil
  end
  for name, terminal_config in pairs(terminals) do
    if vim.deep_equal(cmd, terminal_config.cmd) then
      return name
    end
  end
end

local function is_managed_terminal(terminal)
  return managed_terminal_name(terminal) ~= nil
end

local function terminal_matches_cwd(terminal, cwd)
  return normalize_path(terminal_cwd(terminal)) == normalize_path(cwd)
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

local function terminal_opts(name, cwd)
  return {
    count = terminals[name].count,
    cwd = cwd,
    auto_close = false,
    win = {
      position = "current",
      bo = {
        bufhidden = "hide",
      },
      wo = {
        winbar = "agent",
      },
    },
  }
end

local function get_terminal(name, cwd, create)
  return Snacks.terminal.get(
    terminals[name].cmd,
    vim.tbl_extend("force", terminal_opts(name, cwd), {
      create = create,
    })
  )
end

local function remember_terminal(name, cwd)
  state.last_terminal_name = name
  state.last_terminal_cwd = cwd
end

local function register_agent_terminal(terminal)
  if not terminal or not terminal:buf_valid() or vim.b[terminal.buf].workspace_registered then
    return
  end
  vim.b[terminal.buf].workspace_registered = true
  vim.api.nvim_create_autocmd("TermClose", {
    group = state.augroup,
    buffer = terminal.buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if state.cleaning then
          return
        end
        if state.current_terminal == terminal then
          terminal.win = nil
          state.current_terminal = nil
          state.current_name = nil
          state.workspace.show_agent_help()
        end
        state.workspace.schedule_repair()
      end)
    end,
  })
end

local function show_terminal(name, opts)
  opts = opts or {}
  local cwd = state.workspace.cwd()
  remember_terminal(name, cwd)
  local terminal = get_terminal(name, cwd, false)
  if terminal and not terminal_is_running(terminal) then
    close_terminal(terminal)
    terminal = nil
  end

  local agent_tabpage, agent_win = state.workspace.agent_pane()
  if not agent_tabpage or not agent_win then
    state.workspace.schedule_repair()
    return nil
  end

  local restore_tabpage = vim.api.nvim_get_current_tabpage()
  local restore_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_tabpage(agent_tabpage)
  vim.api.nvim_set_current_win(agent_win)

  if not terminal then
    terminal = get_terminal(name, cwd, true)
  end
  if not terminal or not terminal_is_running(terminal) then
    if terminal then
      close_terminal(terminal)
    end
    vim.notify("Could not open " .. name .. " in the agent workspace", vim.log.levels.ERROR)
    return nil
  end
  register_agent_terminal(terminal)

  if state.current_terminal and state.current_terminal ~= terminal then
    state.current_terminal.win = nil
  end
  if not window_shows_buffer(terminal.win, agent_tabpage, terminal.buf) then
    detach_terminal_window(terminal)
    terminal:show()
  end
  if not window_shows_buffer(terminal.win, agent_tabpage, terminal.buf) then
    vim.notify("Could not show " .. name .. " in the agent tab", vim.log.levels.ERROR)
    return nil
  end

  state.current_terminal = terminal
  state.current_name = name
  if opts.focus == false then
    if vim.api.nvim_tabpage_is_valid(restore_tabpage) then
      vim.api.nvim_set_current_tabpage(restore_tabpage)
      if vim.api.nvim_win_is_valid(restore_win) and vim.api.nvim_win_get_tabpage(restore_win) == restore_tabpage then
        vim.api.nvim_set_current_win(restore_win)
      end
    end
  else
    terminal:focus()
    vim.cmd.startinsert()
  end
  return terminal
end

function M.show(name, opts)
  if not terminals[name] then
    vim.notify("Unknown agent: " .. tostring(name), vim.log.levels.ERROR)
    return
  end
  state.workspace.run_when_ready(function()
    local terminal = show_terminal(name, opts)
    if terminal and opts and opts.on_ready then
      opts.on_ready(terminal)
    end
  end)
end

function M.ensure_visible(opts)
  opts = opts or {}
  if state.current_terminal and terminal_is_running(state.current_terminal) then
    show_terminal(state.current_name or managed_terminal_name(state.current_terminal), { focus = false })
  elseif opts.default then
    show_terminal(opts.default, { focus = false })
  else
    state.workspace.show_agent_help()
  end
end

function M.detach_window()
  if state.current_terminal then
    state.current_terminal.win = nil
  end
end

function M.focus()
  local tabpage, win = state.workspace.agent_pane()
  if
    state.current_terminal
    and terminal_is_running(state.current_terminal)
    and window_shows_buffer(win, tabpage, state.current_terminal.buf)
  then
    state.current_terminal:focus()
    vim.cmd.startinsert()
    return true
  end
  return false
end

local function current_buffer_relative_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Current buffer is not backed by a file", vim.log.levels.WARN)
    return nil
  end
  local absolute_path = vim.fs.normalize(vim.uv.fs_realpath(path) or path)
  local workspace_root = normalize_path(state.workspace.cwd())
  return vim.fs.relpath(workspace_root, absolute_path) or absolute_path
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

local function managed_terminal_candidates(cwd)
  local current_buf = vim.api.nvim_get_current_buf()
  local visible
  local any
  for _, terminal in ipairs(Snacks.terminal.list()) do
    if is_managed_terminal(terminal) and terminal_matches_cwd(terminal, cwd) and terminal_is_running(terminal) then
      if terminal.buf == current_buf then
        return terminal
      end
      visible = visible or (terminal:valid() and terminal)
      any = any or terminal
    end
  end
  return nil, visible, any
end

local function remembered_managed_terminal(cwd)
  if not state.last_terminal_name or normalize_path(state.last_terminal_cwd) ~= normalize_path(cwd) then
    return nil
  end
  local terminal = get_terminal(state.last_terminal_name, cwd, false)
  if terminal and terminal_is_running(terminal) then
    return terminal
  end
end

local function reference_terminal(cwd)
  if
    state.current_terminal
    and terminal_matches_cwd(state.current_terminal, cwd)
    and terminal_is_running(state.current_terminal)
  then
    return state.current_terminal
  end
  local current, visible, any = managed_terminal_candidates(cwd)
  return current or visible or remembered_managed_terminal(cwd) or any
end

local function copy_reference(reference)
  vim.fn.setreg('"', reference)
  pcall(vim.fn.setreg, "+", reference)
end

local function buffer_contains_any(buf, needles)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local line_count = vim.api.nvim_buf_line_count(buf)
  local start = math.max(0, line_count - 200)
  local lines = vim.api.nvim_buf_get_lines(buf, start, line_count, false)
  for _, line in ipairs(lines) do
    for _, needle in ipairs(needles) do
      if line:find(needle, 1, true) then
        return true
      end
    end
  end
  return false
end

local function terminal_is_ready(terminal)
  if not terminal_is_running(terminal) then
    return false
  end
  local cmd = terminal_command(terminal)
  if type(cmd) == "table" and vim.deep_equal(cmd, terminals.opencode.cmd) then
    return buffer_contains_any(terminal.buf, opencode_ready_markers)
  end
  return true
end

local function with_reference_terminal(cwd, callback)
  local terminal = reference_terminal(cwd)
  local name = terminal and managed_terminal_name(terminal) or "opencode"
  M.show(name, { on_ready = callback })
end

local function send_reference(reference)
  if not reference then
    return
  end
  local cwd = state.workspace.cwd()
  with_reference_terminal(cwd, function(terminal)
    if not terminal or not terminal:buf_valid() then
      copy_reference(reference)
      vim.notify("Could not open agent terminal; copied reference instead", vim.log.levels.WARN)
      return
    end

    local attempts = 0
    local function try_send()
      attempts = attempts + 1
      if not terminal:buf_valid() or not terminal_is_running(terminal) then
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
      else
        copy_reference(reference)
        vim.notify("Failed to send reference; copied it instead", vim.log.levels.WARN)
      end
    end
    vim.schedule(try_send)
  end)
end

function M.cleanup()
  if state.cleaning then
    return
  end
  state.cleaning = true
  if state.augroup then
    pcall(vim.api.nvim_del_augroup_by_id, state.augroup)
    state.augroup = nil
  end
  if rawget(_G, "Snacks") then
    for _, terminal in ipairs(Snacks.terminal.list()) do
      if is_managed_terminal(terminal) then
        close_terminal(terminal)
      end
    end
  end
  state.current_terminal = nil
  state.current_name = nil
end

function M.setup(workspace)
  state.workspace = workspace
  state.augroup = vim.api.nvim_create_augroup("workspace_agents", { clear = true })
end

function M.keys()
  return {
    {
      "<M-o>",
      function()
        M.show("opencode")
      end,
      mode = { "n", "t" },
      desc = "Show OpenCode",
    },
    {
      "<M-c>",
      function()
        M.show("claude")
      end,
      mode = { "n", "t" },
      desc = "Show Claude Code",
    },
    {
      "<leader>ao",
      function()
        M.show("opencode")
      end,
      desc = "Show OpenCode",
    },
    {
      "<leader>ac",
      function()
        M.show("claude")
      end,
      desc = "Show Claude Code",
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
end

return M
