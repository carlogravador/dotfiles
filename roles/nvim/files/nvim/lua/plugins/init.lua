-- plugins/init.lua — Plugin manager bootstrap and plugin loading
--
-- This file does two things:
--   1. Bootstraps lazy.nvim (auto-installs it if not present)
--   2. Loads all plugin specs from the plugins/ directory
--
-- lazy.nvim Concepts:
--   - lazy.nvim is a modern plugin manager for Neovim that supports:
--     - Lazy-loading: plugins load only when needed (faster startup)
--     - Lockfile: lazy-lock.json pins exact plugin versions for reproducibility
--     - Automatic installation: plugins install on first launch
--   - Each plugin spec is a Lua table: { "owner/repo", config = function() ... end }
--   - Specs can also be returned from separate files via { import = "plugins.foo" }

-- ── Bootstrap lazy.nvim ──────────────────────────────────────
-- Check if lazy.nvim is already installed. If not, clone it from GitHub.
-- This runs once on a fresh machine; subsequent launches skip this.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",                          -- Partial clone (faster)
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",                             -- Use the latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)                      -- Add lazy.nvim to the runtime path

-- ── Load plugins ─────────────────────────────────────────────
-- Each { import = "plugins.X" } loads lua/plugins/X.lua and uses
-- the table it returns as a plugin spec.
require("lazy").setup({
  { import = "plugins.treesitter" },
  { import = "plugins.lsp" },
  { import = "plugins.cmp" },
  { import = "plugins.fzf" },
  { import = "plugins.nvim-tree" },
  { import = "plugins.lualine" },
  { import = "plugins.dap" },
}, {
  -- lazy.nvim configuration options
  install = {
    -- Try to use the default colorscheme during plugin installation
    colorscheme = { "default" },
  },
  checker = {
    enabled = false,  -- Don't auto-check for plugin updates (run :Lazy update manually)
  },
  change_detection = {
    notify = false,   -- Don't notify when plugin config files change
  },
})
