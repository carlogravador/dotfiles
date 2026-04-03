-- plugin/mini.lua — Small, focused Neovim modules
--
-- mini.nvim is a collection of independent Lua modules that provide
-- common editor features (auto-pairs, surround, etc.) with minimal config.
-- Pinned to the latest semver tag via vim.version.range("*").

vim.pack.add({
  { src = "https://github.com/nvim-mini/mini.nvim", version = vim.version.range("*") },
})

require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.diff").setup()

local map = vim.keymap.set
map("n", "<leader>md", "<cmd>lua MiniDiff.toggle_overlay()<CR>", {desc = "MiniDiff Toggle" })
