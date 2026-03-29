-- plugins/treesitter.lua — Syntax highlighting and code understanding
--
-- Treesitter parses source code into a syntax tree, enabling:
--   - Accurate syntax highlighting (much better than regex-based highlighting)
--   - Smart indentation
--   - Incremental selection (expand/shrink selection by syntax node)
--   - Code folding, text objects, and more
--
-- Treesitter downloads and compiles parsers for each language on demand.
-- The "ensure_installed" list auto-installs parsers on first launch.

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",   -- Stable API; the main branch is an incompatible rewrite requiring Neovim 0.12+
  build = ":TSUpdate",  -- Compile/update parsers when the plugin is installed or updated
  lazy = false,        -- Load immediately (not on demand) to ensure parsers are available for all filetypes
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Parsers to install automatically
      ensure_installed = {
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
      },

      -- Auto-install parsers when entering a buffer with a new file type
      auto_install = true,

      -- ── Highlighting ─────────────────────────────────────────
      highlight = {
        enable = true,
        -- Disable for very large files (performance)
        disable = function(_, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        -- Use treesitter highlighting alongside Vim's regex highlighting.
        -- Set to false if you see duplicate highlights.
        additional_vim_regex_highlighting = false,
      },

      -- ── Indentation ──────────────────────────────────────────
      indent = {
        enable = false,  -- Use treesitter for smart auto-indentation
        -- disable = { "c", "cpp" },  -- cindent handles C/C++ brace indentation better
      },

      -- ── Incremental Selection ────────────────────────────────
      -- Start with a word, then expand the selection to the enclosing
      -- syntax node (expression → statement → block → function → file).
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",    -- Start selection
          node_incremental = "<C-space>",  -- Expand to parent node
          scope_incremental = false,       -- Disabled (use node_incremental)
          node_decremental = "<bs>",       -- Shrink selection
        },
      },
    })

    -- Enable treesitter-based folding per buffer when a fold query exists.
    -- foldmethod/foldexpr must be set as window options, so an autocmd is needed.
    -- highlight.enable = true above already starts the parser; no need to call
    -- vim.treesitter.start() here.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        local ft = vim.bo.filetype
        local lang = vim.treesitter.language.get_lang(ft)

        if lang and vim.treesitter.query.get(lang, "folds") then
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
          vim.wo.foldenable = false  -- start with folds open
        end
      end,
    })
  end,
}
