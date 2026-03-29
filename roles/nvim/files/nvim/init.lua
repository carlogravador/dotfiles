-- init.lua — Neovim entry point
--
-- This file is loaded automatically when Neovim starts. It sets up core
-- editor settings, then Neovim auto-sources every file in plugin/ (in
-- alphabetical order) — no manual require() needed for plugin configs.
--
-- Load order:
--   1. vim.loader    — Cache bytecode for faster require() calls
--   2. core.options  — Set vim options before anything else
--   3. core.keymaps  — Leader key must be set before plugins bind to it
--   4. core.autocmds — Autocommands for editor behavior
--   5. PackChanged   — Hook must exist before any vim.pack.add() call
--   6. plugin/*      — Auto-sourced alphabetically by Neovim

vim.loader.enable()

require("core.options")
require("core.keymaps")
require("core.autocmds")

-- ── Plugin hooks ─────────────────────────────────────────────
-- Defined here (before plugin/ files are sourced) so that hooks fire even
-- during the very first install from the lockfile.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})
