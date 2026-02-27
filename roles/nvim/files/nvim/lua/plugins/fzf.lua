-- plugins/fzf.lua — Fuzzy finder using fzf
--
-- fzf-lua is a Neovim fuzzy finder that uses the fzf binary.
-- It provides fast searching for files, grep results, buffers, help tags, etc.
--
-- Why fzf-lua over telescope.nvim?
--   - Uses the native fzf binary (very fast, especially on large codebases)
--   - Familiar fzf keybindings if you already use fzf in the terminal
--   - Lower overhead than telescope for most search operations

return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",  -- File type icons (optional but nice)
  },
  config = function()
    local fzf = require("fzf-lua")

    fzf.setup({
      -- Use a "borderless" profile for a clean look, then override as needed
      "default-title",
      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        preview = {
          layout = "flex",       -- Auto-switch between horizontal/vertical preview
          flip_columns = 120,    -- Switch to vertical preview if window < 120 cols
        },
      },
      files = {
        -- Use fd for file finding (faster than find, respects .gitignore)
        fd_opts = "--type f --hidden --follow --exclude .git",
      },
      grep = {
        -- Use ripgrep for searching (fast, respects .gitignore)
        rg_opts = "--column --line-number --no-heading --color=always --smart-case",
      },
    })

    -- ── Keymaps ──────────────────────────────────────────────
    local map = vim.keymap.set

    -- File finding
    map("n", "<leader>ff", fzf.files, { desc = "Find files" })
    map("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })

    -- Grep / search
    map("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
    map("n", "<leader>fw", fzf.grep_cword, { desc = "Grep word under cursor" })
    map("v", "<leader>fw", fzf.grep_visual, { desc = "Grep visual selection" })

    -- Buffers & navigation
    map("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
    map("n", "<leader>fh", fzf.helptags, { desc = "Help tags" })
    map("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps" })

    -- LSP integration (find symbols, diagnostics via fzf)
    map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document symbols" })
    map("n", "<leader>fS", fzf.lsp_workspace_symbols, { desc = "Workspace symbols" })
    map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Document diagnostics" })
    map("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Workspace diagnostics" })

    -- Git
    map("n", "<leader>gc", fzf.git_commits, { desc = "Git commits" })
    map("n", "<leader>gs", fzf.git_status, { desc = "Git status" })
  end,
}
