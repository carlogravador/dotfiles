-- plugins/init.lua — Plugin management via vim.pack (Neovim 0.12+)
--
-- vim.pack is Neovim's built-in plugin manager (no external dependencies).
-- It clones Git repositories, manages updates, and loads plugins using
-- Neovim's native package system (:h packages, :h vim.pack).
--
-- Key concepts:
--   - vim.pack.add()   — Install (if missing) and load a list of plugins
--   - Lockfile         — nvim-pack-lock.json in the config dir pins versions
--   - No lazy-loading  — Plugins load immediately on vim.pack.add()
--   - PackChanged      — Autocmd fired after any install, update, or delete
--
-- Managing plugins:
--   :lua vim.pack.update()           — Update all plugins
--   :lua vim.pack.update({'name'})   — Update a specific plugin

-- ── Install and load all plugins ─────────────────────────────
vim.pack.add({
  -- Syntax / Treesitter
  "https://github.com/nvim-treesitter/nvim-treesitter",

  -- LSP infrastructure
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/williamboman/mason-lspconfig.nvim",
  "https://github.com/neovim/nvim-lspconfig",

  -- Completion engine + sources
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help",
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/saadparwaiz1/cmp_luasnip",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/onsails/lspkind.nvim",

  -- Fuzzy finder
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-tree/nvim-web-devicons",

  -- File explorer
  "https://github.com/nvim-tree/nvim-tree.lua",

  -- Statusline
  "https://github.com/nvim-lualine/lualine.nvim",

  -- Debug Adapter Protocol
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/jay-babu/mason-nvim-dap.nvim",

  -- AI
  "https://github.com/github/copilot.vim",
  "https://github.com/folke/sidekick.nvim",

  -- Mini modules (auto-pairs, surround, etc.)
  -- version = vim.version.range("*") tracks the latest semver-tagged release
  { src = "https://github.com/nvim-mini/mini.nvim", version = vim.version.range("*") },
})

-- ── Post-update hook ──────────────────────────────────────────
-- After any plugin install/update/delete, update Treesitter parsers
-- (equivalent to the :TSUpdate build hook in lazy.nvim).
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function()
    local ok, _ = pcall(require, "nvim-treesitter")
    if ok then vim.cmd("TSUpdate") end
  end,
})

-- ── Load plugin configurations ────────────────────────────────
-- Each file sets up its plugin(s) and registers keymaps. Order matters
-- where one plugin depends on another being configured first (e.g., LSP
-- capabilities must be set before mason-lspconfig attaches servers).
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.cmp")
require("plugins.fzf")
require("plugins.nvim-tree")
require("plugins.lualine")
require("plugins.dap")
require("plugins.ai")
require("plugins.mini")
