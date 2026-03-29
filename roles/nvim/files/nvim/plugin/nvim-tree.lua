-- plugin/nvim-tree.lua — File explorer
--
-- nvim-tree provides a side-panel file tree, similar to VSCode's explorer.
-- It supports file operations (create, rename, delete, copy, move),
-- git status indicators, and filtering.
--
-- Usage:
--   <leader>e  — Toggle the file tree
--   Inside the tree:
--     a — Create a new file or directory (append / for directory)
--     r — Rename
--     d — Delete
--     x — Cut
--     c — Copy
--     p — Paste
--     Enter — Open file
--     q — Close tree

vim.pack.add({ "https://github.com/nvim-tree/nvim-tree.lua" })

-- Recommended: disable netrw (Neovim's built-in file explorer)
-- to avoid conflicts with nvim-tree.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  -- Show files that git ignores (dimmed)
  git = {
    enable = true,
    ignore = false,
  },
  -- Show dotfiles
  filters = {
    dotfiles = false,
  },
  -- Appearance
  view = {
    width = 35,
    side = "left",
  },
  renderer = {
    -- Show git status icons next to filenames
    icons = {
      show = {
        git = true,
        file = true,
        folder = true,
        folder_arrow = true,
      },
    },
    -- Highlight files based on git status
    highlight_git = true,
    -- Show indent markers for nested directories
    indent_markers = {
      enable = true,
    },
  },
  -- Automatically resize the tree when opening a file
  actions = {
    open_file = {
      resize_window = true,
    },
  },
})

-- ── Keymaps ──────────────────────────────────────────────
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>E", ":NvimTreeFindFile<CR>", { desc = "Find current file in explorer" })
