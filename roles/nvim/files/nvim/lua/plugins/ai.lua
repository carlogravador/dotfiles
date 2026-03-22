-- plugins/ai.lua -- AI assistant integration
--
-- This file configures AI coding tools for Neovim:
--   1. GitHub Copilot -- inline code completions
--   2. opencode.nvim  -- bridge between Neovim and the OpenCode TUI agent
--
-- opencode.nvim connects to a running OpenCode TUI instance (started with
-- --port) or spawns an embedded terminal. It sends editor context (selections,
-- buffers, diagnostics, etc.) directly to the OpenCode TUI -- no separate
-- chat buffer needed.
--
-- Context placeholders you can use in prompts:
--   @this         -- visual selection, operator range, or cursor position
--   @buffer       -- current buffer contents
--   @buffers      -- all open buffers
--   @visible      -- visible text in viewport
--   @diagnostics  -- LSP diagnostics for current buffer
--   @quickfix     -- quickfix list
--   @diff         -- git diff

return {
  -- ── GitHub Copilot ─────────────────────────────────────────
  -- Inline code suggestions. Type and Copilot suggests completions.
  -- Accept with <Tab>, dismiss with <C-]>, cycle with <M-]>/<M-[>.
  {
    "github/copilot.vim",
  },
  {
    "folke/sidekick.nvim",
    opts = {
    --   -- add any options here
      cli = {
        watch = true,
        win = {
          split = {
            width = 100, -- Adjust as needed
          },
          keys = {
            -- Override prompt key to <leader>pp, terminal mode only
            prompt = { "<C-\\>", "prompt", mode = "t" , desc = "insert prompt or context" },
            stopinsert = { "<S-Esc>", "stopinsert", mode = "t" , desc = "enter normal mode" },
            hide_esc   = { "<S-Esc>", "hide", mode = "n" , desc = "hide the terminal window" },

            -- (optional) disable <C-p> in terminal mode if you want
            -- prompt_ctrl_p = { "<c-p>", function() end, mode = "t", desc = "(disabled)" },
          },
        },
        tools = {
          opencode = {
            -- Use opus 4.6 as default model
            cmd = { "opencode", "--agent", "plan", "--model", "github-copilot/claude-opus-4.6" },
          },
        },
        picker = "fzf-lua"
      },
    },
    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        -- function() require("sidekick.cli").toggle() end,
        function() require("sidekick.cli").toggle({ name = "opencode", focus = true }) end,
        desc = "Sidekick Toggle",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        -- function() require("sidekick.cli").toggle() end,
        function() require("sidekick.cli").toggle({ name = "opencode", focus = true }) end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        -- function() require("sidekick.cli").select() end,
        -- Or to select only installed tools:
        function() require("sidekick.cli").select({ filter = { installed = true } }) end,
        desc = "Select CLI",
      },
      {
        "<leader>ad",
        function() require("sidekick.cli").close() end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "Send File",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>pp",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      -- Example of a keybinding to open opencode directly
      -- {
      --   "<leader>oc",
      --   function() require("sidekick.cli").toggle({ name = "opencode", focus = true }) end,
      --   desc = "Sidekick Toggle Opencode",
      -- },
    },
  }

}
