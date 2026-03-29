-- plugins/treesitter.lua — Syntax highlighting and code understanding
--
-- nvim-treesitter (main branch, requires Neovim 0.12+) provides:
--   - Parser installation and management via :TSInstall / :TSUpdate
--   - Query files for highlighting, folding, indentation, and injections
--
-- In this rewrite, highlighting and folding are pure Neovim built-ins
-- (vim.treesitter); the plugin only supplies the parsers and queries.
-- require("nvim-treesitter.configs").setup() no longer exists.

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",  -- Compile/update parsers when the plugin is installed or updated
  lazy = false,         -- Lazy-loading is not supported by this plugin
  config = function()
    -- Minimal setup; only needed if overriding the default install_dir
    -- (defaults to stdpath('data') .. '/site').
    require("nvim-treesitter").setup()

    -- Install parsers on first launch (no-op if already installed).
    -- Auto-install on new filetypes is handled by the FileType autocmd below.
    require("nvim-treesitter.install").install({
      "bash",
      "c",
      "cmake",
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

    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = "*",
    --   callback = function(ev)
    --     local ft = vim.bo.filetype
    --     local lang = vim.treesitter.language.get_lang(ft)
    --
    --     -- ── Auto-install ──────────────────────────────────────
    --     -- Install the parser for any filetype not in the list above.
    --     if lang then
    --       require("nvim-treesitter.install").install({ lang })
    --     end
    --
    --     -- ── Highlighting ──────────────────────────────────────
    --     -- vim.treesitter.start() enables treesitter highlighting for this
    --     -- buffer. Skip very large files to avoid performance issues.
    --     local max_filesize = 100 * 1024 -- 100 KB
    --     local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    --     if not (ok and stats and stats.size > max_filesize) then
    --       vim.treesitter.start()
    --     end
    --
    --     -- ── Folding ───────────────────────────────────────────
    --     -- vim.wo[0][0] sets the option as truly window+buffer-local (Neovim 0.12+),
    --     -- so it does not bleed into other buffers opened in the same window.
    --     if lang and vim.treesitter.query.get(lang, "folds") then
    --       vim.wo[0][0].foldmethod = "expr"
    --       vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    --       vim.wo.foldenable = false  -- start with folds open
    --     end
    --
    --     -- ── Indentation ───────────────────────────────────────
    --     -- Treesitter indentation is experimental. Uncomment to enable:
    --     -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    --   end,
    -- })
  end,
}
