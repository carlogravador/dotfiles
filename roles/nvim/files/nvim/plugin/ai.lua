-- plugin/ai.lua — AI assistant integration
--
-- This file configures AI coding tools for Neovim:
--   1. GitHub Copilot — inline code completions
--   2. sidekick.nvim  — bridge between Neovim and the OpenCode TUI agent
--
-- sidekick.nvim connects to a running OpenCode TUI instance (started with
-- --port) or spawns an embedded terminal. It sends editor context (selections,
-- buffers, diagnostics, etc.) directly to the OpenCode TUI — no separate
-- chat buffer needed.
--
-- Context placeholders you can use in prompts:
--   @this         — visual selection, operator range, or cursor position
--   @buffer       — current buffer contents
--   @buffers      — all open buffers
--   @visible      — visible text in viewport
--   @diagnostics  — LSP diagnostics for current buffer
--   @quickfix     — quickfix list
--   @diff         — git diff

vim.pack.add({
  "https://github.com/github/copilot.vim",
  "https://github.com/folke/sidekick.nvim",
})

-- ── GitHub Copilot ─────────────────────────────────────────
-- Inline code suggestions. Type and Copilot suggests completions.
-- Accept with <Tab>, dismiss with <C-]>, cycle with <M-]>/<M-[>.
-- (copilot.vim loads its plugin script automatically — no setup call needed)

-- ── sidekick.nvim ───────────────────────────────────────────
require("sidekick").setup({
  cli = {
    watch = true,
    win = {
      split = {
        width = 100,
      },
      keys = {
        -- Override prompt key to <leader>pp, terminal mode only
        prompt = { "<C-\\>", "prompt", mode = "t", desc = "insert prompt or context" },
        stopinsert = { "<S-Esc>", "stopinsert", mode = "t", desc = "enter normal mode" },
        hide_esc   = { "<S-Esc>", "hide", mode = "n", desc = "hide the terminal window" },
      },
    },
    mux = {
      -- Use tmux for terminal multiplexing (optional, can also use embedded terminals)
      enabled = true,
      backend = "tmux",
      create = "split",
      split = {
        vertical = true,
        size = 0.4
      }
    },
    tools = {
      copilot = {
        cmd = { "copilot" },
      },
    },
    picker = "fzf-lua",
  },
})

-- Enable sidekick file watch for attached sessions (configuration workaround for PR #173)
require("sidekick.cli.watch").enable()

-- ── Keymaps ──────────────────────────────────────────────────
local map = vim.keymap.set

map({ "n", "t", "i", "x" }, "<c-.>", function()
  require("sidekick.cli").focus({ name = "copilot"})
end, { desc = "Sidekick Focus" })

map("n", "<leader>aa", function()
  require("sidekick.cli").toggle({ name = "copilot", focus = true })
end, { desc = "Sidekick Toggle" })

map("n", "<leader>as", function()
  require("sidekick.cli").select({ filter = { installed = true } })
end, { desc = "Select CLI" })

map("n", "<leader>ad", function()
  require("sidekick.cli").close()
end, { desc = "Detach a CLI Session" })

map({ "x", "n" }, "<leader>at", function()
  require("sidekick.cli").send({ msg = "{this}" })
end, { desc = "Send This" })

map("n", "<leader>af", function()
  require("sidekick.cli").send({ msg = "{file}" })
end, { desc = "Send File" })

map("x", "<leader>av", function()
  require("sidekick.cli").send({ msg = "{selection}" })
end, { desc = "Send Visual Selection" })

map({ "n", "x" }, "<leader>pp", function()
  require("sidekick.cli").prompt()
end, { desc = "Sidekick Select Prompt" })

map("n", "<tab>", function()
  -- If there is a next edit, jump to it; otherwise apply it if any
  if not require("sidekick").nes_jump_or_apply() then
    return "<Tab>"  -- fallback to normal tab
  end
end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })

-- Example of a keybinding to open opencode directly:
-- map({ "n" }, "<leader>oc", function()
--   require("sidekick.cli").toggle({ name = "opencode", focus = true })
-- end, { desc = "Sidekick Toggle Opencode" })
