-- core/options.lua — Editor options
--
-- These are Neovim's built-in settings (no plugins required).
-- Each option is documented with what it does and why it's useful.
-- See :help option-list for the full reference.

local opt = vim.opt

-- Line numbers
opt.number = true         -- Show absolute line number on current line
opt.relativenumber = true -- Show relative line numbers (makes j/k jumps easy)

-- Tabs & indentation
opt.tabstop = 4           -- Number of spaces a <Tab> character displays as
opt.shiftwidth = 4        -- Number of spaces used for each step of (auto)indent
opt.softtabstop = 4       -- Number of spaces a <Tab> keypress inserts
opt.expandtab = true      -- Convert tabs to spaces
opt.smartindent = true    -- Auto-indent new lines based on syntax

-- Line wrapping
opt.wrap = false          -- Don't wrap long lines (scroll horizontally instead)

-- Search
opt.ignorecase = true     -- Case-insensitive search...
opt.smartcase = true      -- ...unless the query contains uppercase letters
opt.hlsearch = true       -- Highlight all search matches
opt.incsearch = true      -- Show matches as you type the search pattern

-- Appearance
opt.termguicolors = true  -- Enable 24-bit RGB colors in the terminal
opt.signcolumn = "yes"    -- Always show the sign column (prevents text shifting)
opt.cursorline = true     -- Highlight the line the cursor is on
opt.colorcolumn = "100"   -- Show a vertical guide at column 100
opt.scrolloff = 8         -- Keep 8 lines visible above/below the cursor
opt.sidescrolloff = 8     -- Keep 8 columns visible left/right of the cursor

-- Splits
opt.splitright = true     -- Open vertical splits to the right
opt.splitbelow = true     -- Open horizontal splits below

-- Clipboard
opt.clipboard = "unnamedplus"  -- Use the system clipboard for all yank/paste

-- Undo & backup
opt.undofile = true       -- Persist undo history across sessions (saved in ~/.local/state/nvim/undo)
opt.swapfile = false      -- Don't create .swp files (we have undo history + git)
opt.backup = false        -- Don't create backup files

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }  -- Better completion menu behavior
opt.pumheight = 10        -- Limit popup menu height to 10 items

-- Misc
opt.mouse = "a"           -- Enable mouse in all modes (useful for scrolling, resizing splits)
opt.updatetime = 250      -- Faster CursorHold events (used by gitsigns, LSP hover, etc.)
opt.timeoutlen = 300      -- Time to wait for a mapped key sequence (ms)
opt.showmode = false      -- Don't show "-- INSERT --" (lualine shows the mode instead)
opt.fillchars = { eob = " " }  -- Hide ~ characters on empty lines past end of buffer
