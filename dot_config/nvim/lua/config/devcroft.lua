-- Client for Devcroft's authenticated loopback editor APIs.
-- Works only inside a terminal spawned from Devcroft's Editor tab, which
-- injects service-owned credentials:
--   references: DEVCROFT_REFERENCE_API_URL / _TOKEN (+ _REPOSITORY_KEY)
--   previews:   DEVCROFT_PREVIEW_API_URL / _TOKEN (+ _REPOSITORY_KEY)
-- Every function degrades to a warning when those variables are absent.
local M = {}

local request_seq = 0

local function request_id()
  request_seq = request_seq + 1
  local entropy = string.format("%d:%d:%d", os.time(), request_seq, math.random(2147483647))
  return vim.fn.sha256(entropy):sub(1, 24)
end

--- Checkout-relative path of the current buffer with forward slashes.
local function relative_path()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    return nil
  end
  filepath = vim.fs.normalize(filepath)
  local root = vim.fs.normalize(vim.uv.cwd())
  if filepath:sub(1, #root + 1) ~= root .. "/" then
    return nil
  end
  return filepath:sub(#root + 2)
end

--- POST one JSON payload to a Devcroft loopback endpoint asynchronously.
local function post(url, token, payload, label)
  vim.system({
    "curl",
    "--silent",
    "--show-error",
    "--max-time",
    "8",
    "--request",
    "POST",
    url,
    "--header",
    "Authorization: Bearer " .. token,
    "--header",
    "Content-Type: application/json",
    "--data-binary",
    payload,
    "--write-out",
    "\n%{http_code}",
  }, { text = true }, function(result)
    local output = (result.stdout or "") .. (result.stderr or "")
    local status = output:match("(%d%d%d)\n*$")
    if result.code == 0 and status == "202" then
      return -- accepted; Devcroft takes it from here
    end
    vim.notify(
      ("%s rejected (%s): %s"):format(label, status or tostring(result.code), output:gsub("%s+$", "")),
      vim.log.levels.ERROR
    )
  end)
end

--- Send a line-range code reference to the Devcroft Agent tab.
function M.send_reference(start_line, end_line)
  local url = vim.env.DEVCROFT_REFERENCE_API_URL
  local token = vim.env.DEVCROFT_REFERENCE_API_TOKEN
  local repository_key = vim.env.DEVCROFT_REPOSITORY_KEY
  if not (url and token and repository_key) then
    vim.notify("Devcroft reference API is unavailable outside its Editor tab.", vim.log.levels.WARN)
    return
  end
  local path = relative_path()
  if not path then
    vim.notify("Current file is not inside the Devcroft checkout root.", vim.log.levels.ERROR)
    return
  end
  post(
    url,
    token,
    vim.json.encode({
      requestId = request_id(),
      repositoryKey = repository_key,
      path = path,
      startLine = start_line,
      endLine = end_line,
    }),
    "Reference"
  )
end

--- Preview the current buffer's saved content inside the Devcroft window.
function M.send_preview()
  local url = vim.env.DEVCROFT_PREVIEW_API_URL
  local token = vim.env.DEVCROFT_PREVIEW_API_TOKEN
  local repository_key = vim.env.DEVCROFT_REPOSITORY_KEY
  if not (url and token and repository_key) then
    vim.notify("Devcroft preview API is unavailable outside its Editor tab.", vim.log.levels.WARN)
    return
  end
  local path = relative_path()
  if not path then
    vim.notify("Current file is not inside the Devcroft checkout root.", vim.log.levels.ERROR)
    return
  end
  -- Previews render what is on disk; save first so the snapshot is fresh.
  if vim.bo.modified then
    vim.cmd.write()
  end
  post(
    url,
    token,
    vim.json.encode({
      requestId = request_id(),
      repositoryKey = repository_key,
      path = path,
    }),
    "Preview"
  )
end

return M
