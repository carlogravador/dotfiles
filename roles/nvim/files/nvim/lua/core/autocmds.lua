-- core/autocmds.lua — Autocommands
--
-- Autocommands run automatically when certain events happen in Neovim.
--
-- Neovim Concepts:
--   vim.api.nvim_create_augroup(name, { clear = true })
--     Creates a named group. "clear = true" means re-sourcing this file
--     won't create duplicate autocommands.
--   vim.api.nvim_create_autocmd(event, { ... })
--     Registers a function to run when "event" fires.
--     Common events: BufReadPost, TextYankPost, BufWritePre, VimResized, FileType

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight text briefly after yanking (copying)
-- Try it: yank a word with "yiw" and watch it flash.
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
  desc = "Highlight yanked text",
})

-- Restore cursor position when re-opening a file
-- Neovim remembers where you were and jumps back to that line.
-- autocmd("BufReadPost", {
--   group = augroup("restore_cursor", { clear = true }),
--   callback = function()
--     local mark = vim.api.nvim_buf_get_mark(0, '"')
--     local line_count = vim.api.nvim_buf_line_count(0)
--     if mark[1] > 0 and mark[1] <= line_count then
--       pcall(vim.api.nvim_win_set_cursor, 0, mark)
--     end
--   end,
--   desc = "Restore cursor position on file open",
-- })

-- Auto-resize splits when the terminal window is resized
autocmd("VimResized", {
  group = augroup("auto_resize", { clear = true }),
  command = "tabdo wincmd =",
  desc = "Auto-resize splits on terminal resize",
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  command = [[%s/\s\+$//e]],
  desc = "Remove trailing whitespace on save",
})

