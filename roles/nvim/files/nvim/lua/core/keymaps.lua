-- core/keymaps.lua — General keybindings
--
-- This file sets the leader key and defines keymaps that don't depend on any plugins.
-- Plugin-specific keymaps are defined in their respective plugin config files.
--
-- Vim keymap anatomy:
--   vim.keymap.set(mode, lhs, rhs, opts)
--     mode: "n" = normal, "i" = insert, "v" = visual, "x" = visual block, "t" = terminal
--     lhs:  the key combination you press
--     rhs:  the action to perform (command string or Lua function)
--     opts: { desc = "..." } is used by which-key and shown in :map

local map = vim.keymap.set

-- Leader key — Space is the most accessible key for combos
-- Must be set BEFORE any leader-based keymaps or plugin configs
-- Use default leader
-- vim.g.mapleader = " "
-- vim.g.maplocalleader = " "

-- ── Navigation ───────────────────────────────────────────────
-- Move between windows with Ctrl+hjkl (instead of Ctrl+w then hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows with Ctrl+Arrow keys
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- ── Buffers ──────────────────────────────────────────────────
-- map("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
-- map("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
-- map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- ── Quality of life ─────────────────────────────────────────
-- Clear search highlight with Escape
map("n", "<Esc>", function()
  -- If we find a floating window, close it.
  local found_float = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      vim.api.nvim_win_close(win, true)
      found_float = true
    end
  end
  if not found_float then
    if vim.opt.hlsearch:get() then
      vim.fn.setreg('/', '') -- Clear search highlight
    else
      return '<Esc>' -- Default behavior
    end
  end
end, { desc = "Smart Escape: close float or clear search highlight", noremap = true, silent = true })

-- Highlight word under cursor without moving
map('n', '*', function()
  local word = vim.fn.expand('<cword>')
  vim.fn.setreg('/', '\\<' .. word .. '\\>')
  vim.opt.hlsearch = true
end, { noremap = true, silent = true, desc = 'Highlight word under cursor' })


-- Remove trailing whitespace with <leader>cw
map('n', '<leader>cw', function()
  local save_cursor = vim.fn.getpos(".")
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.setpos(".", save_cursor)
end, { noremap = true, silent = true, desc = 'Remove trailing whitespace' })

-- Stay in visual mode when indenting
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Keep cursor centered when searching
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Paste over selection without losing the yanked text
-- (Normally pasting over a selection puts the replaced text in the register)
-- map("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })

-- Delete without yanking (send to black hole register)
-- map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })
