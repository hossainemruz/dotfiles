return {
  "nickjvandyke/opencode.nvim",
  version = "*", -- Latest stable release
  dependencies = {
    -- `snacks.nvim` integration is configured in snacks.lua to avoid opts conflicts
    "folke/snacks.nvim",
  },
  config = function()
    local cached_port

    local function opencode_port()
      if cached_port then
        return cached_port
      end

      local cwd = vim.uv.cwd() or vim.fn.getcwd()
      local base_dir = vim.uv.fs_realpath(cwd) or cwd
      local seed = base_dir .. "::" .. vim.fn.getpid()
      local hash = 0

      for i = 1, #seed do
        hash = (hash * 31 + seed:byte(i)) % 20000
      end

      cached_port = 30000 + hash
      return cached_port
    end

    local function opencode_cmd()
      return "opencode --port " .. opencode_port()
    end

    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        port = function(callback)
          callback(opencode_port())
        end,
        start = function()
          require("opencode.terminal").open(opencode_cmd(), {
            split = "right",
            width = math.floor(vim.o.columns * 0.50),
          })
        end,
        stop = function()
          require("opencode.terminal").close()
        end,
        toggle = function()
          require("opencode.terminal").toggle(opencode_cmd(), {
            split = "right",
            width = math.floor(vim.o.columns * 0.50),
          })
        end,
      },
      lsp = {
        enabled = true,
      },
      ask = {
        prompt = "Ask opencode: ",
      },
    }

    vim.o.autoread = true -- Required for `opts.events.reload`

    local has_which_key, which_key = pcall(require, "which-key")
    if has_which_key then
      which_key.add({
        { "<leader>o", group = "Opencode", icon = "🤖", mode = { "n", "x" } },
      })
    end

    -- Leader-based keymaps to avoid overriding common defaults
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode…" })
    vim.keymap.set({ "n", "x" }, "<leader>os", function()
      require("opencode").select()
    end, { desc = "Execute opencode action…" })
    vim.keymap.set("n", "<leader>ot", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "<leader>or", function()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n", "<leader>ol", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Add line to opencode", expr = true })

    vim.keymap.set("n", "<leader>ou", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "Scroll opencode up" })
    vim.keymap.set("n", "<leader>od", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "Scroll opencode down" })
  end,
}
