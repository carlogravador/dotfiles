-- plugins/mini.lua — Small, focused Neovim modules
--
-- mini.nvim is a collection of independent Lua modules that provide
-- common editor features (auto-pairs, surround, etc.) with minimal config.
-- The version is pinned to the latest semver tag via vim.pack.add() in init.lua.

require("mini.pairs").setup()
require("mini.surround").setup()
