-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy absolute file path" })

-- Devcroft code references ---------------------------------------------------
-- Works only inside a terminal spawned from Devcroft's Editor tab, which
-- injects DEVCROFT_REFERENCE_API_URL / _TOKEN / REPOSITORY_KEY. The mappings
-- degrade to a warning everywhere else.
local reference_seq = 0

local function devcroft_request_id()
  reference_seq = reference_seq + 1
  local entropy = string.format("%d:%d:%d", os.time(), reference_seq, math.random(2147483647))
  return vim.fn.sha256(entropy):sub(1, 24)
end

--- Checkout-relative path of the current buffer with forward slashes.
local function devcroft_relative_path()
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

local function devcroft_send_reference(start_line, end_line)
  local url = vim.env.DEVCROFT_REFERENCE_API_URL
  local token = vim.env.DEVCROFT_REFERENCE_API_TOKEN
  local repository_key = vim.env.DEVCROFT_REPOSITORY_KEY
  if not (url and token and repository_key) then
    vim.notify("Devcroft reference API is unavailable outside its Editor tab.", vim.log.levels.WARN)
    return
  end
  local path = devcroft_relative_path()
  if not path then
    vim.notify("Current file is not inside the Devcroft checkout root.", vim.log.levels.ERROR)
    return
  end
  local payload = vim.json.encode({
    requestId = devcroft_request_id(),
    repositoryKey = repository_key,
    path = path,
    startLine = start_line,
    endLine = end_line,
  })
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
      return -- accepted; Devcroft shows the preview and queues agent input
    end
    vim.notify(
      ("Reference rejected (%s): %s"):format(status or tostring(result.code), output:gsub("%s+$", "")),
      vim.log.levels.ERROR
    )
  end)
end

-- Reference the current line to the Devcroft Agent.
vim.keymap.set("n", "<leader>al", function()
  local line = vim.fn.line(".")
  devcroft_send_reference(line, line)
end, { desc = "Devcroft: reference current line" })

-- Reference a visual selection to the Devcroft Agent.
vim.keymap.set("x", "<leader>as", function()
  local start_line = math.min(vim.fn.line("'<"), vim.fn.line("'>"))
  local end_line = math.max(vim.fn.line("'<"), vim.fn.line("'>"))
  devcroft_send_reference(start_line, end_line)
end, { desc = "Devcroft: reference visual selection" })
