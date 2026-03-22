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
  build = ":TSUpdate",  -- Compile/update parsers when the plugin is installed or updated
  event = { "BufReadPre", "BufNewFile" },  -- Lazy-load when opening a file
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Parsers to install automatically
      ensure_installed = {
        "bash",
        "c",
        "cmake",
        "cpp",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
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
        enable = true,  -- Use treesitter for smart auto-indentation
        disable = { "c", "cpp" },  -- cindent handles C/C++ brace indentation better
      },

      folding = {
        enable = true,  -- Enable Tree-sitter folding
        disable = {},   -- Disable specific languages if needed
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

    -- Consolidated FileType autocmd for treesitter features
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        local ft = vim.bo.filetype
        local lang = vim.treesitter.language.get_lang(ft)

        if not lang or not vim.treesitter.language.add(lang) then
          return
        end

        vim.treesitter.start()

        -- Set folding if available
        if vim.treesitter.query.get(lang, "folds") then
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end

        -- Note: indentexpr is set automatically by the treesitter indent module
        -- (indent = { enable = true } above). No manual override needed here.
      end,
    })
  end,
}
