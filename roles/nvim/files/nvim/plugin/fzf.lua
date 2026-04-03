-- plugin/fzf.lua — Fuzzy finder using fzf

vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

local fzf = require("fzf-lua")

fzf.setup({
  -- Use a "borderless" profile for a clean look, then override as needed
  "fzf-vim",
  winopts = {
    height = 0.85,
    width = 0.80,
    row = 0.35,
    preview = {
      hidden = false,
      default = "builtin",
      -- default = "bat",
      layout = "flex",       -- Auto-switch between horizontal/vertical preview
      flip_columns = 120,    -- Switch to vertical preview if window < 120 cols
    },

  },
  keymap = {
    builtin = {
      ["<C-y>"] = "preview-up",
      ["<C-e>"] = "preview-down",
    },
  },
})

-- ── Commands ─────────────────────────────────────────────
-- :Files [dir]  and  :Rg [dir]  mirror classic fzf.vim commands,
-- with tab-completion for directories so you can scope the search.
vim.api.nvim_create_user_command("Files", function(opts)
  fzf.files({ cwd = opts.args ~= "" and opts.args or nil })
end, { nargs = "?", complete = "dir", desc = "FZF files (optional dir)" })

vim.api.nvim_create_user_command("Rg", function(opts)
  fzf.live_grep({ cwd = opts.args ~= "" and opts.args or nil })
end, { nargs = "?", complete = "dir", desc = "FZF live grep (optional dir)" })

-- ── Keymaps ──────────────────────────────────────────────
local map = vim.keymap.set

-- File finding
map("n", "<leader>ff", fzf.files, { desc = "Find files" })

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
