-- plugin/treesitter.lua — Syntax highlighting and code understanding
--
-- nvim-treesitter (main branch, requires Neovim 0.12+) provides:
--   - Parser installation and management via :TSInstall / :TSUpdate
--   - Query files for highlighting, folding, indentation, and injections
--
-- In this rewrite, highlighting and folding are pure Neovim built-ins
-- (vim.treesitter); the plugin only supplies the parsers and queries.
-- require("nvim-treesitter.configs").setup() no longer exists.
--
-- Parser updates on plugin upgrade are handled by the PackChanged autocmd
-- in init.lua (runs before any plugin/ file is sourced).

vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

-- Minimal setup; only needed if overriding the default install_dir
-- (defaults to stdpath('data') .. '/site').
require("nvim-treesitter").setup()

-- Install parsers on first launch (no-op if already installed).
-- Auto-install on new filetypes is handled by the FileType autocmd below.
require("nvim-treesitter.install").install({
  "bash",
  "cmake",
  "c",
  "cpp",
  "c_sharp",
  "dockerfile",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "make",
  "vim",
  "vimdoc",
  "python",
  "yaml",
})

